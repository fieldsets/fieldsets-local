import pandas as pd
import os
import psycopg2
import json
from functools import reduce
import math

def ArbitraryPitcher(start_date, end_date):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select pitchermlbamid, pitchername, count(*), avg(velo), \
                   sum(case when pitchresult in ('Foul', 'Hard Foul') \
                   then 1 else 0 end), sum(case when pitchresult in \
                   ('Swing Miss', 'Called Strike', '-') then 1 when \
                   pitchresult in ('Foul', 'Hard Foul') AND countbeforepitch \
                   in ('0-0', '0-1', '1-0', '1-1', '2-0', '2-1', '3-0', '3-1') \
                   then 1 else 0 end) from pitches where ghuid in \
                   (select ghuid from schedule where (game_date >= %s \
                   and game_date <= %s and continuationdate is null) OR \
                   (continuationdate >= %s and continuationdate <= %s and \
                   comments like '%%PPD%%') OR (game_date >= %s and \
                   game_date <= %s and continuationdate is not null and \
                   (comments not like '%%PPD%%' OR comments is null))) \
                   and pitchtype <> 'IN' and ghuid in (select ghuid from \
                   game_detail where postseason = false) group by \
                   pitchermlbamid, pitchername", [start_date, end_date, start_date, end_date, start_date, end_date])
    rows = cursor.fetchall()
    colnames = ['pitchermlbamid', 'pitchername', 'num_pitches',
    'avg_velocity', 'num_foul', 'num_plus']
    ie_adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()

    bs_db = 'baseballsavant'
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=bs_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select pl.mlb_id, count(*), \
                   avg(p.launch_speed), avg(p.launch_angle), \
                   avg(p.release_extension) , avg(p.spin_rate) , \
                   avg(p.release_position_x - p.plate_x) , \
                   avg(p.release_position_z - p.plate_z) , \
                   sum(case m.launch_speed_angle_code when 6 then 1 \
                   else 0 end), count(distinct(matchup_id)) \
                   from pitches p join matchups m \
                   on p.matchup_id = m.id join players pl \
                   on m.pitcher_id = pl.id where m.game_id in \
                   (select id from games where game_date >= %s \
                   and game_date <= %s) \
                   group by pl.mlb_id", [start_date, end_date])
    rows = cursor.fetchall()
    colnames = ['pitchermlbamid', 'num_pitches_bs', 'avg_ev','avg_la', 'avg_ext',
    'avg_spin', 'avg_x_mov', 'avg_z_mov', 'num_barrel', 'num_pa']
    bs_adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()

    leaderboard = [ie_adv_pt, bs_adv_pt]
    adv_pt = reduce(lambda left,right: pd.merge(left,right,on=['pitchermlbamid'],how='outer'), leaderboard)

    if(adv_pt.empty == False):
        adv_pt['foul_pct'] = adv_pt.apply(lambda row: 100 * (int(row['num_foul']) / int(row['num_pitches'])), axis = 1)
        adv_pt['plus_pct'] = adv_pt.apply(lambda row: 100 * (int(row['num_plus']) / int(row['num_pitches'])), axis = 1)
        adv_pt['barrel_pct'] = adv_pt.apply(lambda row: float('NaN') if math.isnan(row['num_barrel']) else 100 * (int(row['num_barrel']) / int(row['num_pa'])), axis = 1)

    return(adv_pt)

def MonthlyPitcher(year, month):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_monthly_advanced_pitcher where \
                    year = %s and month = %s", [year, month])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def HalfPitcher(year, half):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_half_advanced_pitcher where \
                    year = %s and half = %s", [year, half])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def AnnualPitcher(year):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_annual_advanced_pitcher where \
                    year = %s", [year])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def ArbitraryHitter(start_date, end_date):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select hittermlbamid, hittername, sum(\"N\"), \
                   sum(\"RHP\"), sum(\"LHP\"), AVG(\"MPH\"), SUM(num_whiff), \
                   SUM(num_swing), SUM(num_cs), SUM(num_foul), \
                   case when SUM(at_bats) > 0 then SUM(at_bats) else 1 end, \
                   SUM(first_pitch_swing), SUM(num_plus), SUM(ozone), \
                   SUM(swingozone), SUM(contactozone), SUM(earlyocon), \
                   SUM(lateocon), SUM(num_pitches), AVG(avg_ev), \
                   AVG(avg_la), SUM(num_barrels) \
                   from leaderboard_advanced_hitter \
                   where game_date >= %s and \
                   game_date <= %s \
                   group by hittermlbamid, hittername",
                    [start_date, end_date])
    rows = cursor.fetchall()
    colnames = ['hittermlbamid', 'hittername', 'N', 'RHP', 'LHP', 'MPH',
    'num_whiff', 'num_swing', 'num_cs', 'num_foul', 'at_bats',
    'first_pitch_swing', 'num_plus', 'ozone', 'swingozone', 'contactozone',
    'earlyocon', 'lateocon', 'num_pitches', 'avg_ev', 'avg_la',
    'num_barrels']
    adv_hit = pd.DataFrame(rows, columns = colnames)
    db_connection.close()

    if(adv_hit.empty == False):
        adv_hit['foul_pct'] = adv_hit.apply(lambda row: 100 * (int(row['num_foul']) / int(row['N'])), axis = 1)
        adv_hit['barrel_pct'] = adv_hit.apply(lambda row: 100 * (int(row['num_barrels']) / int(row['at_bats'])), axis = 1)
        adv_hit['plus_pct'] = adv_hit.apply(lambda row: 100 * (int(row['num_plus']) / int(row['N'])), axis = 1)
        adv_hit['first_pitch_swing_pct'] = adv_hit.apply(lambda row: float('NaN') if row['at_bats'] == 0 else 100 * (int(row['first_pitch_swing']) / int(row['at_bats'])), axis = 1)
        adv_hit['eoc_pct'] = adv_hit.apply(lambda row: float('Nan') if row['contactozone'] == 0 else 100 * (int(row['earlyocon']) / int(row['contactozone'])), axis = 1)
        adv_hit['loc_pct'] = adv_hit.apply(lambda row: float('NaN') if row['contactozone'] == 0 else 100 * (int(row['lateocon']) / int(row['contactozone'])), axis = 1)

    return(adv_hit)

def MonthlyHitter(year, month):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_monthly_advanced_hitter where \
                    year = %s and month = %s", [year, month])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def HalfHitter(year, half):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_half_advanced_hitter where \
                    year = %s and half = %s", [year, half])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def AnnualHitter(year):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_annual_advanced_hitter where \
                    year = %s", [year])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def ArbitraryPitchType(start_date, end_date):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select pitchermlbamid, pitchername, pitchtype, \
                    count(*), avg(velo), \
                    sum(case pitchresult when 'Foul' then 1 \
                    when 'Hard Foul' then 1 else 0 end), \
                    sum(case when pitchresult = 'Swing Miss' then 1 \
                    when pitchresult = 'Called Strike' then 1 \
                    when pitchresult = 'Foul' AND (strikes = 0 OR strikes = 1) then 1 \
                    when pitchresult = 'Hard Foul' AND (strikes = 0 OR strikes = 1) then 1 \
                    when pitchresult = '-' then 1 else 0 end) \
                    from pitches where ghuid in ( select ghuid \
                    from schedule where game_date >= %s \
                    and game_date <= %s) and pitchtype != 'IN' \
                    group by pitchermlbamid, pitchername, pitchtype",
                    [start_date, end_date])
    rows = cursor.fetchall()
    colnames = ['pitchermlbamid', 'pitchername', 'pitchtype',
    'num_pitches', 'avg_velocity', 'num_foul', 'num_plus']
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()

    #bs_db = 'baseballsavant'
    #db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=bs_db, user=pl_user, password=pl_password)
    #cursor = db_connection.cursor()
    #cursor.execute("select pl.mlb_id, p.pitch_type_abbreviation, count(*), \
    #                avg(p.launch_speed), avg(p.launch_angle), \
    #                avg(p.release_extension) , avg(p.spin_rate) , \
    #                avg(p.release_position_x - p.plate_x) , \
    #                avg(p.release_position_z - p.plate_z) , \
    #                sum(case m.launch_speed_angle_code when 6 then 1 \
    #                else 0 end) from pitches p join matchups m \
    #                on p.matchup_id = m.id join players pl \
    #                on m.pitcher_id = pl.id where m.game_id in \
    #                (select id from games where game_date >= %s \
    #                and game_date <= %s) \
    #                group by pl.mlb_id, p.pitch_type_abbreviation",
    #                [start_date, end_date])
    # rows = cursor.fetchall()
    # colnames = ['mlb_id', 'pitch_type', 'num_pitches_bs', 'avg_ev',
    # 'avg_la', 'avg_ext', 'avg_spin', 'avg_x_mov', 'avg_z_mov', 'is_barrel']
    # bs_adv_pt = pd.DataFrame(rows, colnames)
    # db_connection.close()
    #
    # pitch_map = {
    #     "Unknown": "UNK",
    #     "SL": "SL",
    #     "FF": "FA",
    #     "CH": "CH",
    #     "CU": "CU",
    #     "FT": "FA",
    #     "SI": "SI",
    #     "FC": "FC",
    #     "FS": "FS",
    #     "KC": "CU",
    #     "EP": "EP",
    #     "KN": "KN",
    #     "FO": "FS",
    # }

    if(adv_pt.empty == False):
        adv_pt['foul_pct'] = adv_pt.apply(lambda row: 100 * (int(row['num_foul']) / int(row['num_pitches'])), axis = 1)
        adv_pt['plus_pct'] = adv_pt.apply(lambda row: 100 * (int(row['num_plus']) / int(row['num_pitches'])), axis = 1)

    return(adv_pt)

def MonthlyPitchType(year, month):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_monthly_advanced_pitchtype where \
                    year = %s and month = %s", [year, month])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def HalfPitchType(year, half):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_half_advanced_pitchtype where \
                    year = %s and half = %s", [year, half])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def AnnualPitchType(year):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_annual_advanced_pitchtype where \
                    year = %s", [year])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)
