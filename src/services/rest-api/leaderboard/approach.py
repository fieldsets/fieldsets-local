import pandas as pd
import os
import psycopg2
import json
from functools import reduce

def MonthlyPitcher(year, month):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_monthly_approach_pitcher where \
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
    cursor.execute("select * from leaderboard_half_approach_pitcher where \
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
    cursor.execute("select * from leaderboard_annual_approach_pitcher where \
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
    cursor.execute("select hittermlbamid, hittername, sum(\"n\"), sum(inside), \
                    sum(h_middle_loc), sum(outside), sum(high), sum(middle), \
                    sum(low), sum(heart), sum(fb), sum(early), \
                    sum(early_secondary), sum(late), sum(late_secondary), \
                    sum(zone), sum(non_bip_str), sum(early_bip) \
                    from leaderboard_approach_hitter \
                    where date >= %s and date <= %s \
                    group by hittermlbamid, hittername",
                    [start_date, end_date])
    rows = cursor.fetchall()
    colnames = ['hittermlbamid', 'hittername', 'num_pitches', 'num_inside',
    'num_h_middle', 'num_outside', 'num_high', 'num_middle', 'num_low',
    'num_heart', 'num_fb', 'num_early', 'num_early_secondary', 'num_late',
    'num_late_secondary', 'num_zone', 'num_non_bip_str', 'num_early_bip']
    app_hit = pd.DataFrame(rows, columns = colnames)
    db_connection.close()

    app_hit['inside_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_inside']) / int(row['num_pitches'])), axis = 1)
    app_hit['h_mid_loc_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_h_middle']) / int(row['num_pitches'])), axis = 1)
    app_hit['outside_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_outside']) / int(row['num_pitches'])), axis = 1)
    app_hit['high_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_high']) / int(row['num_pitches'])), axis = 1)
    app_hit['middle_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_middle']) / int(row['num_pitches'])), axis = 1)
    app_hit['low_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_low']) / int(row['num_pitches'])), axis = 1)
    app_hit['heart_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_heart']) / int(row['num_pitches'])), axis = 1)
    app_hit['fb_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_fb']) / int(row['num_pitches'])), axis = 1)
    app_hit['early_sec_pct'] = app_hit.apply(lambda row: 0 if row['num_early'] == 0 else 100 * (int(row['num_early_secondary']) / int(row['num_early'])), axis = 1)
    app_hit['late_sec_pct'] = app_hit.apply(lambda row: 0 if row['num_late'] == 0 else 100 * (int(row['num_late_secondary']) / int(row['num_late'])), axis = 1)
    app_hit['zone_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_zone']) / int(row['num_pitches'])), axis = 1)
    app_hit['non_bip_str_pct'] = app_hit.apply(lambda row: 100 * (int(row['num_non_bip_str']) / int(row['num_pitches'])), axis = 1)
    app_hit['early_bip_pct'] = app_hit.apply(lambda row: 0 if row['num_early'] == 0 else 100 * (int(row['num_early_bip']) / int(row['num_early'])), axis = 1)
    return(app_hit)

def MonthlyHitter(year, month):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_monthly_approach_hitter where \
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
    cursor.execute("select * from leaderboard_half_approach_hitter where \
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
    cursor.execute("select * from leaderboard_annual_approach_hitter where \
                    year = %s", [year])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)

def MonthlyPitchType(year, month):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    cursor.execute("select * from leaderboard_monthly_approach_pitchtype where \
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
    cursor.execute("select * from leaderboard_half_approach_pitchtype where \
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
    cursor.execute("select * from leaderboard_annual_approach_pitchtype where \
                    year = %s", [year])
    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    adv_pt = pd.DataFrame(rows, columns = colnames)
    db_connection.close()
    return(adv_pt)
