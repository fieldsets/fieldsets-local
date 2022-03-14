import pandas as pd
import os
import psycopg2
from datetime import datetime
from helpers import *
import json as json

def build_cursor_execute_list(leaderboard, year, month, half, arbitrary_start, arbitrary_end, handedness,
                              opponent_handedness, league, division, team, home_away, **kwargs):
    print("Building cursor list at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Building cursor list at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    cursor_list = list()
    args = [year, month, half, arbitrary_start, arbitrary_end, handedness, opponent_handedness, league, division,
            team, home_away]
    join_args = [year, month, half, arbitrary_start, arbitrary_end, home_away]

    if leaderboard == 'pitch':
        for arg in args:
            if arg != 'NA':
                cursor_list.append(arg)

    if leaderboard in ['pitch', 'pitcher']:
        for arg in join_args:
            if arg != 'NA':
                cursor_list.append(arg)

    for arg in args:
        if arg != 'NA':
            cursor_list.append(arg)

    print("Cursor list built at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Cursor list built at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    return cursor_list


def generate_leaderboard_statistics(leaderboard, handedness, opponent_handedness, league, division, team, home_away, year,
                         month, half, arbitrary_start, arbitrary_end, **kwargs):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    cursor = db_connection.cursor()
    query = create_search_query(leaderboard, handedness, opponent_handedness, league, division, team, home_away, year,
                         month, half, arbitrary_start, arbitrary_end)
    cursor_list = build_cursor_execute_list(leaderboard, year, month, half, arbitrary_start, arbitrary_end,
                                            handedness, opponent_handedness, league, division, team, home_away)
    cursor.execute(query, cursor_list)

    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    raw = pd.DataFrame(rows, columns=colnames)
    db_connection.close()

    #To-do: consolidate dataframe by playerid

    raw['avg_velocity'] = raw.apply(lambda row: velocity(row['num_velo'], row['total_velo']), axis=1)
    raw['barrel_pct'] = raw.apply(lambda row: barrelpercentage(row['num_barrel'], row['num_batted_ball_event']), axis=1)
    raw['foul_pct'] = raw.apply(lambda row: foulpercentage(row['num_foul'], row['num_pitches']), axis=1)
    raw['plus_pct'] = raw.apply(lambda row: foulpercentage(row['num_plus_pitch'], row['num_pitches']), axis=1)
    raw['first_pitch_swing_pct'] = raw.apply(lambda row: firstpitchswingpercentage(row['num_first_pitch_swing'],
                                                                                   row['num_ab']), axis=1)
    raw['early_o_contact_pct'] = raw.apply(lambda row: earlyocontactpercentage(row['num_early_o_contact'],
                                                                               row['num_o_contact']), axis=1)
    raw['late_o_contact_pct'] = raw.apply(lambda row: lateocontactpercentage(row['num_late_o_contact'],
                                                                               row['num_o_contact']), axis=1)
    raw['avg_launch_speed'] = raw.apply(lambda row: launchspeed(row['num_launch_speed'], row['total_launch_speed']),
                                        axis=1)
    raw['avg_launch_angle'] = raw.apply(lambda row: launchangle(row['num_launch_angle'], row['total_launch_angle']),
                                        axis=1)
    raw['avg_release_extension'] = raw.apply(lambda row: releaseextension(row['num_release_extension'],
                                                              row['total_release_extension']), axis=1)
    raw['avg_spin_rate'] = raw.apply(lambda row: spinrate(row['num_spin_rate'], row['total_spin_rate']), axis=1)
    raw['avg_x_movement'] = raw.apply(lambda row: xmovement(row['num_x_movement'], row['total_x_movement']), axis=1)
    raw['avg_z_movement'] = raw.apply(lambda row: zmovement(row['num_z_movement'], row['total_z_movement']), axis=1)
    raw['armside_pct'] = raw.apply(lambda row: armsidepercentage(row['num_armside'], row['num_pitches']), axis=1)
    raw['gloveside_pct'] = raw.apply(lambda row: glovesidepercentage(row['num_gloveside'], row['num_pitches']), axis=1)
    raw['inside_pct'] = raw.apply(lambda row: insidepercentage(row['num_inside'], row['num_pitches']), axis=1)
    raw['outside_pct'] = raw.apply(lambda row: outsidepercentage(row['num_outside'], row['num_pitches']), axis=1)
    raw['high_pct'] = raw.apply(lambda row: highlocpercentage(row['num_high'], row['num_pitches']), axis=1)
    raw['horizonal_middle_location_pct'] = raw.apply(lambda row: hmidlocpercentage(row['num_horizontal_middle'],
                                                                                   row['num_pitches']), axis=1)
    raw['vertical_middle_location_pct'] = raw.apply(lambda row: vmidlocpercentage(row['num_middle'],
                                                                                   row['num_pitches']), axis=1)
    raw['low_pct'] = raw.apply(lambda row: lowlocpercentage(row['num_low'], row['num_pitches']), axis=1)
    raw['heart_pct'] = raw.apply(lambda row: heartpercentage(row['num_heart'], row['num_pitches']), axis=1)
    raw['early_pct'] = raw.apply(lambda row: earlypercentage(row['num_early'], row['num_pitches']), axis=1)
    raw['behind_pct'] = raw.apply(lambda row: behindpercentage(row['num_behind'], row['num_pitches']), axis=1)
    raw['late_pct'] = raw.apply(lambda row: latepercentage(row['num_late'], row['num_pitches']), axis=1)
    raw['zone_pct'] = raw.apply(lambda row: zonepercentage(row['num_zone'], row['num_pitches']), axis=1)
    raw['non_bip_strike_pct'] = raw.apply(lambda row: nonbipstrikepercentage(row['num_non_bip_strike'],
                                                                             row['num_pitches']), axis=1)
    raw['early_bip_pct'] = raw.apply(lambda row: earlybippercentage(row['num_early_bip'], row['num_early']), axis=1)
    raw['groundball_pct'] = raw.apply(lambda row: groundballpercentage(row['num_ground_ball'],
                                                                       row['num_batted_ball_event']), axis=1)
    raw['linedrive_pct'] = raw.apply(lambda row: linedrivepercentage(row['num_line_drive'],
                                                                     row['num_batted_ball_event']), axis=1)
    raw['flyball_pct'] = raw.apply(lambda row: flyballpercentage(row['num_fly_ball'],
                                                                 row['num_batted_ball_event']), axis=1)
    raw['infield_flyball_pct'] = raw.apply(lambda row: infieldflyballpercentage(row['num_if_fly_ball'],
                                                                       row['num_batted_ball_event']), axis=1)
    raw['weak_pct'] = raw.apply(lambda row: weakpercentage(row['num_weak_bip'],
                                                           row['num_batted_ball_event']), axis=1)
    raw['medium_pct'] = raw.apply(lambda row: mediumpercentage(row['num_medium_bip'],
                                                               row['num_batted_ball_event']), axis=1)
    raw['hard_pct'] = raw.apply(lambda row: hardpercentage(row['num_hard_bip'],
                                                           row['num_batted_ball_event']), axis=1)
    raw['pull_pct'] = raw.apply(lambda row: pullpercentage(row['num_pulled_bip'],
                                                           row['num_batted_ball_event']), axis=1)
    raw['opposite_field_pct'] = raw.apply(lambda row: oppositefieldpercentage(row['num_opposite_bip'],
                                                                              row['num_batted_ball_event']), axis=1)
    raw['babip_pct'] = raw.apply(lambda row: babip(row['num_hit'], row['num_hr'], row['num_ab'], row['num_k'],
                                                   row['num_sacrifice']), axis=1)
    raw['bacon_pct'] = raw.apply(lambda row: bacon(row['num_hit'], row['num_ab'], row['num_k'], row['num_sacrifice']),
                                 axis=1)
    raw['swing_pct'] = raw.apply(lambda row: swingpercentage(row['num_swing'], row['num_pitches']), axis=1)
    raw['o_swing_pct'] = raw.apply(lambda row: oswingpercentage(row['num_o_swing'], row['num_swing']), axis=1)
    raw['z_swing_pct'] = raw.apply(lambda row: zswingpercentage(row['num_z_swing'], row['num_swing']), axis=1)
    raw['contact_pct'] = raw.apply(lambda row: contactpercentage(row['num_contact'], row['num_swing']), axis=1)
    raw['o_contact_pct'] = raw.apply(lambda row: ocontactpercentage(row['num_o_contact'], row['num_o_swing']), axis=1)
    raw['z_contact_pct'] = raw.apply(lambda row: zcontactpercentage(row['num_z_contact'], row['num_z_swing']), axis=1)
    raw['swinging_strike_pct'] = raw.apply(lambda row: swingingstrikepercentage(row['num_whiff'],
                                                                                row['num_swing']), axis=1)
    raw['called_strike_pct'] = raw.apply(lambda row: calledstrikepercentage(row['num_called_strike'],
                                                                            row['num_pitches']), axis=1)
    raw['csw_pct'] = raw.apply(lambda row: calledstrikespluswhiffspercentage(row['num_called_strike_plus_whiff'],
                                                                            row['num_pitches']), axis=1)
    raw['early_called_strike_pct'] = raw.apply(lambda row: earlycalledstrikepercentage(row['num_early_called_strike'],
                                                                                row['num_early']), axis=1)
    raw['late_o_swing_pct'] = raw.apply(lambda row: latesecondarypercentage(row['num_late_o_swing'],
                                                                              row['num_late']), axis=1)
    raw['f_strike_pct'] = raw.apply(lambda row: fstrikepercentage(row['num_first_pitch_strike'], row['num_pa']), axis=1)
    raw['true_f_strike_pct'] = raw.apply(lambda row: truefstrikepercentage(row['num_true_first_pitch_strike'],
                                                                  row['num_pa']), axis=1)
    raw['put_away_pct'] = raw.apply(lambda row: putawaypercentage(row['num_put_away'], row['num_late']), axis=1)
    raw['batting_average'] = raw.apply(lambda row: battingaverage(row['num_hit'], row['num_ab']), axis=1)
    raw['on_base_pct'] = raw.apply(lambda row: onbasepercentage(row['num_hit'], row['num_bb'], row['num_hbp'],
                                                                row['num_ab'], row['num_sacrifice']), axis=1)
    raw['strikeout_pct'] = raw.apply(lambda row: strikeoutpercentage(row['num_k'], row['num_pa']), axis=1)
    raw['walk_pct'] = raw.apply(lambda row: walkpercentage(row['num_bb'], row['num_pa']), axis=1)
    raw['hr_flyball_pct'] = raw.apply(lambda row: homerunflyballratio(row['num_hr'], row['num_fly_ball']), axis=1)
    raw['whip'] = raw.apply(lambda row: whip(row['num_hit'], row['num_bb'], row['num_outs']), axis=1)
    raw['num_ip'] = raw.apply(lambda row: ip(row['num_outs']), axis=1)

    if leaderboard == 'pitch':
        raw['usage_pct'] = raw.apply(lambda row: usagepercentage(row['num_pitches'], row['total_num_pitches']), axis=1)
    elif leaderboard in ['pitcher', 'hitter']:
        raw['fastball_pct'] = raw.apply(lambda row: fastballpercentage(row['num_fastball'], row['num_pitches']), axis=1)
        raw['early_secondary_pct'] = raw.apply(lambda row: earlysecondarypercentage(row['num_early_secondary'],
                                                                                    row['num_early']), axis=1)
        raw['late_secondary_pct'] = raw.apply(lambda row: latesecondarypercentage(row['num_late_secondary'],
                                                                                  row['num_late']), axis=1)

    # Need to implement wOBA
    # Need to implement feed for boxscore information into the DB
    # Need to add strike and ball to pl_leaderboard_v2 for pitchtype standard

    return raw


def generate_leaderboard_statistics_persist(leaderboard, handedness, opponent_handedness, league, division, team, home_away, year,
                         month, half, arbitrary_start, arbitrary_end, **kwargs):
    pl_host = os.getenv('PL_DB_HOST')
    pl_db = os.getenv('PL_DB_DATABASE', 'pitcher-list')
    pl_user = os.getenv('PL_DB_USER')
    pl_password = os.getenv('PL_DB_PW')
    db_connection = get_connection()
    cursor = db_connection.cursor()
    query = create_search_query(leaderboard, handedness, opponent_handedness, league, division, team, home_away, year,
                         month, half, arbitrary_start, arbitrary_end)
    cursor_list = build_cursor_execute_list(leaderboard, year, month, half, arbitrary_start, arbitrary_end,
                                            handedness, opponent_handedness, league, division, team, home_away)

    print("Gathering DB results at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Gathering DB results at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    cursor.execute(query, cursor_list)

    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    raw = pd.DataFrame(rows, columns=colnames)

    print("DB results gathered at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("DB results gathered results at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    #To-do: consolidate dataframe by playerid
    print("Generating statistics at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Generating statistics at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    raw['avg_velocity'] = raw.apply(lambda row: velocity(row['num_velo'], row['total_velo']), axis=1)
    raw['barrel_pct'] = raw.apply(lambda row: barrelpercentage(row['num_barrel'], row['num_batted_ball_event']), axis=1)
    raw['foul_pct'] = raw.apply(lambda row: foulpercentage(row['num_foul'], row['num_pitches']), axis=1)
    raw['plus_pct'] = raw.apply(lambda row: foulpercentage(row['num_plus_pitch'], row['num_pitches']), axis=1)
    raw['first_pitch_swing_pct'] = raw.apply(lambda row: firstpitchswingpercentage(row['num_first_pitch_swing'],
                                                                                   row['num_ab']), axis=1)
    raw['early_o_contact_pct'] = raw.apply(lambda row: earlyocontactpercentage(row['num_early_o_contact'],
                                                                               row['num_o_contact']), axis=1)
    raw['late_o_contact_pct'] = raw.apply(lambda row: lateocontactpercentage(row['num_late_o_contact'],
                                                                               row['num_o_contact']), axis=1)
    raw['avg_launch_speed'] = raw.apply(lambda row: launchspeed(row['num_launch_speed'], row['total_launch_speed']),
                                        axis=1)
    raw['avg_launch_angle'] = raw.apply(lambda row: launchangle(row['num_launch_angle'], row['total_launch_angle']),
                                        axis=1)
    raw['avg_release_extension'] = raw.apply(lambda row: releaseextension(row['num_release_extension'],
                                                              row['total_release_extension']), axis=1)
    raw['avg_spin_rate'] = raw.apply(lambda row: spinrate(row['num_spin_rate'], row['total_spin_rate']), axis=1)
    raw['avg_x_movement'] = raw.apply(lambda row: xmovement(row['num_x_movement'], row['total_x_movement']), axis=1)
    raw['avg_z_movement'] = raw.apply(lambda row: zmovement(row['num_z_movement'], row['total_z_movement']), axis=1)
    raw['armside_pct'] = raw.apply(lambda row: armsidepercentage(row['num_armside'], row['num_pitches']), axis=1)
    raw['gloveside_pct'] = raw.apply(lambda row: glovesidepercentage(row['num_gloveside'], row['num_pitches']), axis=1)
    raw['inside_pct'] = raw.apply(lambda row: insidepercentage(row['num_inside'], row['num_pitches']), axis=1)
    raw['outside_pct'] = raw.apply(lambda row: outsidepercentage(row['num_outside'], row['num_pitches']), axis=1)
    raw['high_pct'] = raw.apply(lambda row: highlocpercentage(row['num_high'], row['num_pitches']), axis=1)
    raw['horizonal_middle_location_pct'] = raw.apply(lambda row: hmidlocpercentage(row['num_horizontal_middle'],
                                                                                   row['num_pitches']), axis=1)
    raw['vertical_middle_location_pct'] = raw.apply(lambda row: vmidlocpercentage(row['num_middle'],
                                                                                   row['num_pitches']), axis=1)
    raw['low_pct'] = raw.apply(lambda row: lowlocpercentage(row['num_low'], row['num_pitches']), axis=1)
    raw['heart_pct'] = raw.apply(lambda row: heartpercentage(row['num_heart'], row['num_pitches']), axis=1)
    raw['early_pct'] = raw.apply(lambda row: earlypercentage(row['num_early'], row['num_pitches']), axis=1)
    raw['behind_pct'] = raw.apply(lambda row: behindpercentage(row['num_behind'], row['num_pitches']), axis=1)
    raw['late_pct'] = raw.apply(lambda row: latepercentage(row['num_late'], row['num_pitches']), axis=1)
    raw['zone_pct'] = raw.apply(lambda row: zonepercentage(row['num_zone'], row['num_pitches']), axis=1)
    raw['non_bip_strike_pct'] = raw.apply(lambda row: nonbipstrikepercentage(row['num_non_bip_strike'],
                                                                             row['num_pitches']), axis=1)
    raw['early_bip_pct'] = raw.apply(lambda row: earlybippercentage(row['num_early_bip'], row['num_early']), axis=1)
    raw['groundball_pct'] = raw.apply(lambda row: groundballpercentage(row['num_ground_ball'],
                                                                       row['num_batted_ball_event']), axis=1)
    raw['linedrive_pct'] = raw.apply(lambda row: linedrivepercentage(row['num_line_drive'],
                                                                     row['num_batted_ball_event']), axis=1)
    raw['flyball_pct'] = raw.apply(lambda row: flyballpercentage(row['num_fly_ball'],
                                                                 row['num_batted_ball_event']), axis=1)
    raw['infield_flyball_pct'] = raw.apply(lambda row: infieldflyballpercentage(row['num_if_fly_ball'],
                                                                       row['num_batted_ball_event']), axis=1)
    raw['weak_pct'] = raw.apply(lambda row: weakpercentage(row['num_weak_bip'],
                                                           row['num_batted_ball_event']), axis=1)
    raw['medium_pct'] = raw.apply(lambda row: mediumpercentage(row['num_medium_bip'],
                                                               row['num_batted_ball_event']), axis=1)
    raw['hard_pct'] = raw.apply(lambda row: hardpercentage(row['num_hard_bip'],
                                                           row['num_batted_ball_event']), axis=1)
    raw['pull_pct'] = raw.apply(lambda row: pullpercentage(row['num_pulled_bip'],
                                                           row['num_batted_ball_event']), axis=1)
    raw['opposite_field_pct'] = raw.apply(lambda row: oppositefieldpercentage(row['num_opposite_bip'],
                                                                              row['num_batted_ball_event']), axis=1)
    raw['babip_pct'] = raw.apply(lambda row: babip(row['num_hit'], row['num_hr'], row['num_ab'], row['num_k'],
                                                   row['num_sacrifice']), axis=1)
    raw['bacon_pct'] = raw.apply(lambda row: bacon(row['num_hit'], row['num_ab'], row['num_k'], row['num_sacrifice']),
                                 axis=1)
    raw['swing_pct'] = raw.apply(lambda row: swingpercentage(row['num_swing'], row['num_pitches']), axis=1)
    raw['o_swing_pct'] = raw.apply(lambda row: oswingpercentage(row['num_o_swing'], row['num_swing']), axis=1)
    raw['z_swing_pct'] = raw.apply(lambda row: zswingpercentage(row['num_z_swing'], row['num_swing']), axis=1)
    raw['contact_pct'] = raw.apply(lambda row: contactpercentage(row['num_contact'], row['num_swing']), axis=1)
    raw['o_contact_pct'] = raw.apply(lambda row: ocontactpercentage(row['num_o_contact'], row['num_o_swing']), axis=1)
    raw['z_contact_pct'] = raw.apply(lambda row: zcontactpercentage(row['num_z_contact'], row['num_z_swing']), axis=1)
    raw['swinging_strike_pct'] = raw.apply(lambda row: swingingstrikepercentage(row['num_whiff'],
                                                                                row['num_swing']), axis=1)
    raw['called_strike_pct'] = raw.apply(lambda row: calledstrikepercentage(row['num_called_strike'],
                                                                            row['num_pitches']), axis=1)
    raw['csw_pct'] = raw.apply(lambda row: calledstrikespluswhiffspercentage(row['num_called_strike_plus_whiff'],
                                                                            row['num_pitches']), axis=1)
    raw['early_called_strike_pct'] = raw.apply(lambda row: earlycalledstrikepercentage(row['num_early_called_strike'],
                                                                                row['num_early']), axis=1)
    raw['late_o_swing_pct'] = raw.apply(lambda row: latesecondarypercentage(row['num_late_o_swing'],
                                                                              row['num_late']), axis=1)
    raw['f_strike_pct'] = raw.apply(lambda row: fstrikepercentage(row['num_first_pitch_strike'], row['num_pa']), axis=1)
    raw['true_f_strike_pct'] = raw.apply(lambda row: truefstrikepercentage(row['num_true_first_pitch_strike'],
                                                                  row['num_pa']), axis=1)
    raw['put_away_pct'] = raw.apply(lambda row: putawaypercentage(row['num_put_away'], row['num_late']), axis=1)
    raw['batting_average'] = raw.apply(lambda row: battingaverage(row['num_hit'], row['num_ab']), axis=1)
    raw['on_base_pct'] = raw.apply(lambda row: onbasepercentage(row['num_hit'], row['num_bb'], row['num_hbp'],
                                                                row['num_ab'], row['num_sacrifice']), axis=1)
    raw['strikeout_pct'] = raw.apply(lambda row: strikeoutpercentage(row['num_k'], row['num_pa']), axis=1)
    raw['walk_pct'] = raw.apply(lambda row: walkpercentage(row['num_bb'], row['num_pa']), axis=1)
    raw['hr_flyball_pct'] = raw.apply(lambda row: homerunflyballratio(row['num_hr'], row['num_fly_ball']), axis=1)
    raw['whip'] = raw.apply(lambda row: whip(row['num_hit'], row['num_bb'], row['num_outs']), axis=1)
    raw['num_ip'] = raw.apply(lambda row: ip(row['num_outs']), axis=1)

    if leaderboard == 'pitch':
        raw['usage_pct'] = raw.apply(lambda row: usagepercentage(row['num_pitches'], row['total_num_pitches']), axis=1)
    elif leaderboard in ['pitcher', 'hitter']:
        raw['fastball_pct'] = raw.apply(lambda row: fastballpercentage(row['num_fastball'], row['num_pitches']), axis=1)
        raw['early_secondary_pct'] = raw.apply(lambda row: earlysecondarypercentage(row['num_early_secondary'],
                                                                                    row['num_early']), axis=1)
        raw['late_secondary_pct'] = raw.apply(lambda row: latesecondarypercentage(row['num_late_secondary'],
                                                                                  row['num_late']), axis=1)

    # Need to implement wOBA
    # Need to implement feed for boxscore information into the DB
    # Need to add strike and ball to pl_leaderboard_v2 for pitchtype standard

    print("Statistics generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Statistics generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    return raw


def collect_leaderboard_statistics(leaderboard, handedness, opponent_handedness, league, division, team,
                                            home_away, year,
                                            month, half, arbitrary_start, arbitrary_end, **kwargs):

    db_connection = get_connection()
    cursor = db_connection.cursor()
    query = create_search_query(leaderboard, handedness, opponent_handedness, league, division, team, home_away, year,
                                month, half, arbitrary_start, arbitrary_end)
    cursor_list = build_cursor_execute_list(leaderboard, year, month, half, arbitrary_start, arbitrary_end,
                                            handedness, opponent_handedness, league, division, team, home_away)

    print("Gathering DB results at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Gathering DB results at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    cursor.execute(query, cursor_list)

    rows = cursor.fetchall()
    colnames = [desc[0] for desc in cursor.description]
    raw = pd.DataFrame(rows, columns=colnames)

    print("DB results gathered at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("DB results gathered results at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    # To-do: consolidate dataframe by playerid
    print("Generating statistics at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Generating statistics at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    if year != 'NA':
        woba_year = year
    else:
        woba_year = datetime.strptime(arbitrary_end, '%Y-%m-%d').strftime('%Y')

    if leaderboard in ['pitcher', 'hitter']:
        raw['woba'] = raw.apply(lambda row: weightedonbasepercentage(woba_year, row['num_ab'], row['num_bb'], row['num_ibb'],
                                                                     row['num_hbp'], row['num_sacrifice'], row['num_1b'],
                                                                     row['num_2b'], row['num_3b'], row['num_hr']),
                                axis=1)
    elif leaderboard == 'pitch':
        raw['woba'] = raw.apply(lambda row: weightedonbasepercentage(woba_year, (row['num_outs'] + row['num_hit']), row['num_bb'], row['num_ibb'],
                                                                     row['num_hbp'], row['num_sacrifice'], row['num_1b'],
                                                                     row['num_2b'], row['num_3b'], row['num_hr']),
                                axis=1)
    # Need to implement feed for boxscore information into the DB
    # Need to add strike and ball to pl_leaderboard_v2 for pitchtype standard

    print("Statistics generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Statistics generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    return raw

def leaderboard_collection(leaderboard, tab, handedness, opponent_handedness, league, division, team, home_away, year,
                           month, half, arbitrary_start, arbitrary_end):
    db_connection = get_connection()
    cursor = db_connection.cursor()
    query = create_search_query_2_1(leaderboard, tab, handedness, opponent_handedness, league, division, team,
                                    home_away, year, month, half, arbitrary_start, arbitrary_end)
    cursor_list = build_cursor_execute_list(leaderboard, year, month, half, arbitrary_start, arbitrary_end,
                                            handedness, opponent_handedness, league, division, team, home_away)

    print("Gathering DB results at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Gathering DB results at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    try:
        cursor.execute(query, cursor_list)
    except Exception:
        raise
    else:
        rows = cursor.fetchall()

    colnames = [desc[0] for desc in cursor.description]
    raw = pd.DataFrame(rows, columns=colnames)

    print("DB results gathered at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("DB results gathered results at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    print("Generating statistics at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Generating statistics at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    if tab in ['overview']:
        if year != 'NA':
            if year == '2021':
                woba_year = '2020'
            else:
                woba_year = year
        else:
            temp_year = datetime.strptime(arbitrary_end, '%Y-%m-%d').strftime('%Y')
            if temp_year == '2021':
                woba_year = '2020'
            else:
                woba_year = datetime.strptime(arbitrary_end, '%Y-%m-%d').strftime('%Y')

        if leaderboard == 'hitter':
            raw['woba'] = raw.apply(
                lambda row: round(weightedonbasepercentage(woba_year, row['num_ab'], row['num_bb'], row['num_ibb'],
                                                     row['num_hbp'], row['num_sacrifice'], row['num_1b'],
                                                     row['num_2b'], row['num_3b'], row['num_hr']), 3), axis=1)
            raw.drop(['num_ab', 'num_bb', 'num_ibb', 'num_hbp', 'num_sacrifice', 'num_1b', 'num_2b', 'num_3b'],
                     axis=1, inplace=True)
            
    # Need to implement feed for boxscore information into the DB
    # Need to add strike and ball to pl_leaderboard_v2 for pitchtype standard

    print("Statistics generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Statistics generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    return raw