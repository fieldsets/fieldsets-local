from pathlib import Path
import logging
from datetime import datetime
import dateutil.parser as parser


def leaderboard_select_generator(leaderboard):
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'
    choices = {
        'pitcher': sql_directory / 'pitcher_select.sql',
        'pitch': sql_directory / 'pitcher_pitch_type_select.sql',
        'hitter': sql_directory / 'hitter_select.sql'
    }
    return open(choices.get(leaderboard), 'r').read()


def filter_select_generator(leaderboard, handedness, opponent_handedness, league, home_away, **kwargs):
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'

    handedness_select = ''
    opponent_handedness_select = ''
    league_select = ''
    home_away_select = ''

    if handedness != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            handedness_select = open(sql_directory / 'pitcher_side_select.sql', 'r').read()
        elif leaderboard == 'hitter':
            handedness_select = open(sql_directory / 'hitter_side_select.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of handedness and position submitted')

    if opponent_handedness != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            opponent_handedness_select = open(sql_directory / 'pitcher_side_against_select.sql', 'r').read()
        elif leaderboard == 'hitter':
            opponent_handedness_select = open(sql_directory / 'hitter_side_against_select.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of opponent handedness and position submitted')

    if league != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            league_select = open(sql_directory / 'pitcher_league_select.sql', 'r').read()
        elif leaderboard == 'hitter':
            league_select = open(sql_directory / 'hitter_league_select.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of opponent handedness and position submitted')

    if home_away != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            home_away_select = open(sql_directory / 'pitcher_home_away_select.sql', 'r').read()
        elif leaderboard == 'hitter':
            home_away_select = open(sql_directory / 'hitter_home_away_select.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of opponent handedness and position submitted')

    select_query = handedness_select + opponent_handedness_select + league_select + home_away_select

    return select_query


def filter_where_generator(leaderboard, handedness, opponent_handedness, league, division, team, home_away, **kwargs):
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'

    handedness_where = ''
    opponent_handedness_where = ''
    league_where = ''
    home_away_where = ''
    division_where = ''
    team_where = ''

    if handedness != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            handedness_where = open(sql_directory / 'pitcher_side_where.sql', 'r').read()
        elif leaderboard == 'hitter':
            handedness_where = open(sql_directory / 'hitter_side_where.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of handedness and position submitted')

    if opponent_handedness != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            opponent_handedness_where = open(sql_directory / 'hitter_side_where.sql', 'r').read()
        elif leaderboard == 'hitter':
            opponent_handedness_where = open(sql_directory / 'pitcher_side_where.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of opponent handedness and position submitted')

    if league != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            league_where = open(sql_directory / 'pitcher_league_where.sql', 'r').read()
        elif leaderboard == 'hitter':
            league_where = open(sql_directory / 'hitter_league_where.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of league and position submitted')

    if division != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            division_where = open(sql_directory / 'pitcher_division_where.sql', 'r').read()
        elif leaderboard == 'hitter':
            division_where = open(sql_directory / 'hitter_division_where.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of division and position submitted')

    if team != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            team_where = open(sql_directory / 'pitcher_team_where.sql', 'r').read()
        elif leaderboard == 'hitter':
            team_where = open(sql_directory / 'hitter_team_where.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of team and position submitted')

    if home_away != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            home_away_where = open(sql_directory / 'pitcher_home_away_where.sql', 'r').read()
        elif leaderboard == 'hitter':
            home_away_where = open(sql_directory / 'hitter_home_away_where.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of opponent handedness and position submitted')

    where_query = handedness_where + opponent_handedness_where + league_where + division_where + team_where + home_away_where

    return where_query


def table_select_generator(year, select):
    choices = {
        2015: 'from pl_leaderboard_v2_daily_2015',
        2016: 'from pl_leaderboard_v2_daily_2016',
        2017: 'from pl_leaderboard_v2_daily_2017',
        2018: 'from pl_leaderboard_v2_daily_2018',
        2019: 'from pl_leaderboard_v2_daily_2019',
        2020: 'from pl_leaderboard_v2_daily_2020',
        2021: 'from pl_leaderboard_v2_daily_2021',
        2022: 'from pl_leaderboard_v2_daily_2022'
    }
    return choices.get(year) + ' ' + select + '\n'


def date_where_generator(year, month, half, arbitrary_start, arbitrary_end, select, **kwargs):
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'
    date_where = ''
    month_where = ''
    half_where = ''

    if arbitrary_start != 'NA' and arbitrary_end != 'NA':
        date_where = open(sql_directory / 'arb_date_where.sql', 'r').read()
    elif year != 'NA':
        table_year = year
        date_where = open(sql_directory / 'base_where.sql', 'r').read()
    else:
        logging.error('Unable to generate sql query based on dates provided')

    if month != 'NA':
        month_where = open(sql_directory / 'month_where.sql', 'r').read()

    if half in ['First', 'Second']:
        half_where = open(sql_directory / 'half_where.sql', 'r').read()

    return date_where + month_where + half_where


def leaderboard_group_by_generator(leaderboard):
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'
    choices = {
        'pitcher': sql_directory / 'pitcher_group_by.sql',
        'pitch': sql_directory / 'pitcher_pitch_type_group_by.sql',
        'hitter': sql_directory / 'hitter_group_by.sql'
    }
    return open(choices.get(leaderboard), 'r').read()


def filter_group_by_generator(leaderboard, handedness, opponent_handedness, league, home_away, **kwargs):
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'

    handedness_group_by = ''
    opponent_handedness_group_by = ''
    league_group_by = ''
    home_away_group_by = ''

    if handedness != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            handedness_group_by = open(sql_directory / 'pitcher_side_group_by.sql', 'r').read()
        elif leaderboard == 'hitter':
            handedness_group_by = open(sql_directory / 'hitter_side_group_by.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of handedness and position submitted')

    if opponent_handedness != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            opponent_handedness_group_by = open(sql_directory / 'pitcher_side_against_group_by.sql', 'r').read()
        elif leaderboard == 'hitter':
            opponent_handedness_group_by = open(sql_directory / 'hitter_side_against_group_by.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of opponent handedness and position submitted')

    if league != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            league_group_by = open(sql_directory / 'pitcher_league_group_by.sql', 'r').read()
        elif leaderboard == 'hitter':
            league_group_by = open(sql_directory / 'hitter_league_group_by.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of opponent handedness and position submitted')

    if home_away != 'NA':
        if leaderboard in ['pitcher', 'pitch']:
            home_away_group_by = open(sql_directory / 'pitcher_home_away_group_by.sql', 'r').read()
        elif leaderboard == 'hitter':
            home_away_group_by = open(sql_directory / 'hitter_home_away_group_by.sql', 'r').read()
        else:
            logging.warning('Incorrect combination of opponent handedness and position submitted')

    group_by_query = handedness_group_by + opponent_handedness_group_by + league_group_by + home_away_group_by

    return group_by_query


def pitch_aggregation_subquery_generator(handedness, opponent_handedness, league, division, team, home_away,
                                         year, month, half, arbitrary_start, arbitrary_end, **kwargs):
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'
    join_query = ''
    table_select = ''

    table_year = ''
    table = 'from pl_leaderboard_v2_daily sub\n'
    if (arbitrary_start != 'NA' and arbitrary_end != 'NA') and \
            (parser.parse(arbitrary_start).year == parser.parse(arbitrary_end).year):
        table_year = parser.parse(arbitrary_start).year
    elif year != 'NA':
        table_year = year

    if table_year != '':
        table_select = table_select_generator(int(table_year), 'sub')
    else:
        table_select = table

    date_where = date_where_generator(year, month, half, arbitrary_start, arbitrary_end, 'sub')
    filter_where = filter_where_generator('pitch', handedness, opponent_handedness, league, division, team,
                                          home_away)
    sub_query_select = open(sql_directory / 'sub_query_select.sql', 'r').read()
    sub_query_join = open(sql_directory / 'sub_query_join.sql', 'r').read()
    join_query = sub_query_select + table_select + date_where + filter_where + sub_query_join
    return join_query


def select_generator(leaderboard, tab):

    select_query = str()

    leaderboard_tabs = {
        "pitch": {
            "advanced": ['avg_velocity', 'barrel_pct', 'plus_pct', 'num_pitches'],
            "approach": ['armside_pct','horizonal_middle_location_pct', 'gloveside_pct', 'high_pct',
                         'vertical_middle_location_pct', 'low_pct', 'heart_pct', 'early_pct','behind_pct', 'late_pct',
                         'zone_pct', 'non_bip_strike_pct', 'early_bip_pct', 'num_pitches'],
            "plate_discipline": ['o_swing_pct', 'zone_pct', 'swinging_strike_pct', 'called_strike_pct', 'csw_pct',
                                 'contact_pct', 'z_contact_pct', 'o_contact_pct', 'swing_pct', 'num_pitches',
                                 'early_called_strike_pct', 'late_o_swing_pct', 'f_strike_pct', 'true_f_strike_pct'],
            "batted_ball": ['groundball_pct', 'linedrive_pct', 'flyball_pct', 'infield_flyball_pct', 'weak_pct',
                            'medium_pct', 'hard_pct', 'pull_pct', 'opposite_field_pct', 'babip_pct', 'bacon_pct', 'num_pitches'],
            "overview": ['avg_velocity', 'usage_pct', 'o_swing_pct', 'zone_pct', 'swinging_strike_pct',
                         'called_strike_pct', 'csw_pct', 'put_away_pct', 'batting_average', 'num_pitches', 'plus_pct'],
            "standard": ['num_pitches', 'num_pa', 'num_hit', 'num_1b', 'num_2b', 'num_3b', 'num_hr', 'num_k', 'num_bb',
                         'batting_average']
        },
        "pitcher": {
            "advanced": ['avg_velocity', 'barrel_pct', 'foul_pct', 'plus_pct', 'num_ip'],
            "approach": ['armside_pct', 'horizonal_middle_location_pct', 'gloveside_pct', 'high_pct',
                         'vertical_middle_location_pct', 'low_pct', 'heart_pct', 'fastball_pct', 'num_ip',
                         'early_secondary_pct', 'late_secondary_pct', 'zone_pct', 'non_bip_strike_pct', 'early_bip_pct'],
            "plate_discipline": ['o_swing_pct', 'zone_pct', 'swinging_strike_pct', 'called_strike_pct', 'csw_pct',
                                 'contact_pct', 'z_contact_pct', 'o_contact_pct', 'swing_pct', 'early_called_strike_pct',
                                 'late_o_swing_pct', 'f_strike_pct', 'true_f_strike_pct', 'num_ip'],
            "batted_ball": ['groundball_pct', 'linedrive_pct', 'flyball_pct', 'infield_flyball_pct', 'weak_pct',
                            'medium_pct', 'hard_pct', 'pull_pct', 'opposite_field_pct', 'babip_pct',
                            'bacon_pct', 'num_ip'],
            "overview": ['num_ip', 'whip', 'strikeout_pct', 'walk_pct', 'swinging_strike_pct', 'csw_pct',
                         'put_away_pct', 'babip_pct', 'hr_flyball_pct', 'plus_pct'],
            "standard": ['num_pitches', 'num_hit', 'num_ip', 'num_hr', 'num_k', 'num_bb'],
        },
        "hitter": {
            "advanced": ['foul_pct', 'plus_pct', 'first_pitch_swing_pct', 'early_o_contact_pct',
                         'late_o_contact_pct', 'num_pa'],
            "approach": ['inside_pct', 'horizonal_middle_location_pct', 'outside_pct', 'high_pct',
                         'vertical_middle_location_pct', 'low_pct', 'heart_pct', 'fastball_pct',
                         'early_secondary_pct', 'late_secondary_pct', 'zone_pct', 'non_bip_strike_pct',
                         'early_bip_pct', 'num_pa'],
            "plate_discipline": ['o_swing_pct', 'zone_pct', 'swinging_strike_pct', 'called_strike_pct', 'csw_pct',
                                 'contact_pct', 'z_contact_pct', 'o_contact_pct', 'swing_pct', 'early_called_strike_pct',
                                 'late_o_swing_pct', 'f_strike_pct', 'true_f_strike_pct', 'num_pa'],
            "batted_ball": ['groundball_pct', 'linedrive_pct', 'flyball_pct', 'infield_flyball_pct', 'weak_pct',
                            'medium_pct', 'hard_pct', 'pull_pct', 'opposite_field_pct',
                            'babip_pct', 'bacon_pct', 'num_pa'],
            "overview": ['num_pa', 'num_hr', 'batting_average', 'on_base_pct', 'babip_pct', 'hr_flyball_pct',
                         'swinging_strike_pct', 'woba', 'strikeout_pct', 'walk_pct'],
            "standard": ['num_pa', 'num_hit', 'num_1b', 'num_2b', 'num_3b', 'num_hr', 'num_k', 'num_bb']
        }
    }

    statistic_sql_map = {
        "num_pitches": ", sum(base.num_pitches) as num_pitches\n",
        "avg_velocity": ", round(sum(total_velo) / nullif(sum(num_velo), 0), 1) as avg_velocity\n",
        "barrel_pct": ", round(100 * (sum(num_barrel) / nullif(sum(num_batted_ball_event), 0)), 1) as barrel_pct\n",
        "foul_pct": ", round(100 * (sum(num_foul) / nullif(sum(base.num_pitches), 0)), 1) as foul_pct\n",
        "plus_pct": ", round(100 * (sum(num_plus_pitch) / nullif(sum(base.num_pitches), 0)), 1) as plus_pct\n",
        "first_pitch_swing_pct": ", round(100 * (sum(num_first_pitch_swing) / nullif(sum(num_ab), 0)), 1) as first_pitch_swing_pct\n",
        "early_o_contact_pct": ", round(100 * (sum(num_early_o_contact) / nullif(sum(num_o_contact), 0)), 1) as early_o_contact_pct\n",
        "late_o_contact_pct": ", round(100 * (sum(num_late_o_contact) / nullif(sum(num_o_contact), 0)), 1) as late_o_contact_pct\n",
        "avg_launch_speed": ", round((sum(total_launch_speed) / nullif(sum(num_launch_speed), 0))::decimal, 1) as avg_launch_speed\n",
        "avg_launch_angle": ", round((sum(total_launch_angle) / nullif(sum(num_launch_angle), 0))::decimal, 1) as avg_launch_angle\n",
        "avg_release_extension": ", round((sum(total_release_extension) / nullif(sum(num_release_extension), 0))::decimal, 1) as avg_release_extension\n",
        "avg_spin_rate": ", round((sum(total_spin_rate) / nullif(sum(num_spin_rate), 0))::decimal, 1) as avg_spin_rate\n",
        "avg_x_movement": ", round((sum(total_x_movement) / nullif(sum(num_x_movement), 0))::decimal, 1) as avg_x_movement\n",
        "avg_z_movement": ", round((sum(total_z_movement) / nullif(sum(num_z_movement), 0))::decimal, 1) as avg_z_movement\n",
        "armside_pct": ", round(100 * (sum(num_armside) / nullif(sum(base.num_pitches), 0)), 1) as armside_pct\n",
        "gloveside_pct": ", round(100 * (sum(num_gloveside) / nullif(sum(base.num_pitches), 0)), 1) as gloveside_pct\n",
        "inside_pct": ", round(100 * (sum(num_inside) / nullif(sum(base.num_pitches), 0)), 1) as inside_pct\n",
        "outside_pct": ", round(100 * (sum(num_outside) / nullif(sum(base.num_pitches), 0)), 1) as outside_pct\n",
        "high_pct": ", round(100 * (sum(num_high) / nullif(sum(base.num_pitches), 0)), 1) as high_pct\n",
        "horizonal_middle_location_pct": ", round(100 * (sum(num_horizontal_middle) / nullif(sum(base.num_pitches), 0)), 1) as horizonal_middle_location_pct\n",
        "vertical_middle_location_pct": ", round(100 * (sum(num_middle) / nullif(sum(base.num_pitches), 0)), 1) as vertical_middle_location_pct\n",
        "low_pct": ", round(100 * (sum(num_low) / nullif(sum(base.num_pitches), 0)), 1) as low_pct\n",
        "heart_pct": ", round(100 * (sum(num_heart) / nullif(sum(base.num_pitches), 0)), 1) as heart_pct\n",
        "early_pct": ", round(100 * (sum(num_early) / nullif(sum(base.num_pitches), 0)), 1) as early_pct\n",
        "behind_pct": ", round(100 * (sum(num_behind) / nullif(sum(base.num_pitches), 0)), 1) as behind_pct\n",
        "late_pct": ", round(100 * (sum(num_late) / nullif(sum(base.num_pitches), 0)), 1) as late_pct\n",
        "zone_pct": ", round(100 * (sum(num_zone) / nullif(sum(base.num_pitches), 0)), 1) as zone_pct\n",
        "non_bip_strike_pct": ", round(100 * (sum(num_non_bip_strike) / nullif(sum(base.num_pitches), 0)), 1) as non_bip_strike_pct\n",
        "early_bip_pct": ", round(100 * (sum(num_early_bip) / nullif(sum(base.num_early), 0)), 1) as early_bip_pct\n",
        "groundball_pct": ", round(100 * (sum(num_ground_ball) / nullif(sum(num_batted_ball_event), 0)), 1) as groundball_pct\n",
        "linedrive_pct": ", round(100 * (sum(num_line_drive) / nullif(sum(num_batted_ball_event), 0)), 1) as linedrive_pct\n",
        "flyball_pct": ", round(100 * (sum(num_fly_ball) / nullif(sum(num_batted_ball_event), 0)), 1) as flyball_pct\n",
        "infield_flyball_pct": ", round(100 * (sum(num_if_fly_ball) / nullif(sum(num_batted_ball_event), 0)), 1) as infield_flyball_pct\n",
        "weak_pct": ", round(100 * (sum(num_weak_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as weak_pct\n",
        "medium_pct": ", round(100 * (sum(num_medium_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as medium_pct\n",
        "hard_pct": ", round(100 * (sum(num_hard_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as hard_pct\n",
        "pull_pct": ", round(100 * (sum(num_pulled_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as pull_pct\n",
        "opposite_field_pct": ", round(100 * (sum(num_opposite_bip) / nullif(sum(num_batted_ball_event), 0)), 1) as opposite_field_pct\n",
        "swing_pct": ", round(100 * (sum(num_swing) / nullif(sum(base.num_pitches), 0)), 1) as swing_pct\n",
        "o_swing_pct": ", round(100 * (sum(num_o_swing) / nullif(sum(num_swing), 0)), 1) as o_swing_pct\n",
        "z_swing_pct": ", round(100 * (sum(num_z_swing) / nullif(sum(num_swing), 0)), 1) as z_swing_pct\n",
        "contact_pct": ", round(100 * (sum(num_contact) / nullif(sum(num_swing), 0)), 1) as contact_pct\n",
        "o_contact_pct": ", round(100 * (sum(num_o_contact) / nullif(sum(num_o_swing), 0)), 1) as o_contact_pct\n",
        "z_contact_pct": ", round(100 * (sum(num_z_contact) / nullif(sum(num_z_swing), 0)), 1) as z_contact_pct\n",
        "swinging_strike_pct": ", round(100 * (sum(num_whiff) / nullif(sum(base.num_pitches), 0)), 1) as swinging_strike_pct\n",
        "called_strike_pct": ", round(100 * (sum(num_called_strike) / nullif(sum(base.num_pitches), 0)), 1) as called_strike_pct\n",
        "csw_pct": ", round(100 * (sum(num_called_strike_plus_whiff) / nullif(sum(base.num_pitches), 0)), 1) as csw_pct\n",
        "early_called_strike_pct": ", round(100 * (sum(num_early_called_strike) / nullif(sum(num_early), 0)), 1) as early_called_strike_pct\n",
        "late_o_swing_pct": ", round(100 * (sum(num_late_o_swing) / nullif(sum(num_late), 0)), 1) as late_o_swing_pct\n",
        "f_strike_pct": ", round(100 * (sum(num_first_pitch_strike) / nullif(sum(num_pa), 0)), 1) as f_strike_pct\n",
        "true_f_strike_pct": ", round(100 * (sum(num_true_first_pitch_strike) / nullif(sum(num_pa), 0)), 1) as true_f_strike_pct\n",
        "put_away_pct": ", round(100 * (sum(num_put_away) / nullif(sum(num_late), 0)), 1) as put_away_pct\n",
        "batting_average": ", round(sum(num_hit) / nullif(sum(num_ab), 0), 3) as batting_average\n",
        "strikeout_pct": ", round(100 * (sum(num_k) / nullif(sum(num_pa), 0)), 1) as strikeout_pct\n",
        "walk_pct": ", round(100 * (sum(num_bb) / nullif(sum(num_pa), 0)), 1) as walk_pct\n",
        "hr_flyball_pct": ", round(100 * (sum(num_hr) / nullif(sum(num_fly_ball), 0)), 1) as hr_flyball_pct\n",
        "babip_pct": ", round(((sum(num_hit) - sum(num_hr)) / nullif((sum(num_ab) - sum(num_hr) - sum(num_k) + sum(num_sacrifice)), 0)), 3) as babip_pct\n",
        "bacon_pct": ", round(sum(num_hit) / nullif((sum(num_ab) - sum(num_k) + sum(num_sacrifice)), 0), 3) as bacon_pct\n",
        "on_base_pct": ", round((sum(num_hit) + sum(num_bb) + sum(num_hbp)) / nullif((sum(num_ab) + sum(num_bb) + sum(num_sacrifice) + sum(num_hbp)), 0), 3) as on_base_pct\n",
        "whip": ", round((sum(num_hit) + sum(num_bb)) / nullif(sum(num_outs) / 3, 0), 2) as whip\n",
        "num_ip": ", round(nullif(sum(num_outs) / 3, 0), 1) as num_ip\n",
        "num_zone": ", sum(num_zone) as num_zone\n",
        "total_velo": ", sum(total_velo) as total_velo\n",
        "num_velo": ", sum(num_velo) as num_velo\n",
        "num_armside": ", sum(num_armside) as num_armside\n",
        "num_gloveside": ", sum(num_gloveside) as num_gloveside\n",
        "num_inside": ", sum(num_inside) as num_inside\n",
        "num_outside": ", sum(num_outside) as num_outside\n",
        "num_horizontal_middle": ", sum(num_horizontal_middle) as num_horizontal_middle\n",
        "num_high": ", sum(num_high) as num_high\n",
        "num_middle": ", sum(num_middle) as num_middle\n",
        "num_low": ", sum(num_low) as num_low\n",
        "num_heart": ", sum(num_heart) as num_heart\n",
        "num_early": ", sum(num_early) as num_early\n",
        "num_late": ", sum(num_late) as num_late\n",
        "num_behind": ", sum(num_behind) as num_behind\n",
        "num_non_bip_strike": ", sum(num_non_bip_strike) as num_non_bip_strike\n",
        "num_batted_ball_event": ", sum(num_batted_ball_event) as num_batted_ball_event\n",
        "num_early_bip": ", sum(num_early_bip) as num_early_bip\n",
        "num_fastball": ", sum(num_fastball) as num_fastball\n",
        "num_secondary": ", sum(num_secondary) as num_secondary\n",
        "num_early_secondary": ", sum(num_early_secondary) as num_early_secondary\n",
        "num_late_secondary": ", sum(num_late_secondary) as num_late_secondary\n",
        "num_called_strike": ", sum(num_called_strike) as num_called_strike\n",
        "num_early_called_strike": ", sum(num_early_called_strike) as num_early_called_strike\n",
        "num_called_strike_plus_whiff": ", sum(num_called_strike_plus_whiff) as num_called_strike_plus_whiff\n",
        "num_put_away": ", sum(num_put_away) as num_put_away\n",
        "num_swing": ", sum(num_swing) as num_swing\n",
        "num_whiff": ", sum(num_whiff) as num_whiff\n",
        "num_contact": ", sum(num_contact) as num_contact\n",
        "num_foul": ", sum(num_foul) as num_foul\n",
        "num_first_pitch_swing": ", sum(num_first_pitch_swing) as num_first_pitch_swing\n",
        "num_first_pitch_strike": ", sum(num_first_pitch_strike) as num_first_pitch_strike\n",
        "num_true_first_pitch_strike": ", sum(num_true_first_pitch_strike) as num_true_first_pitch_strike\n",
        "num_plus_pitch": ", sum(num_plus_pitch) as num_plus_pitch\n",
        "num_z_swing": ", sum(num_z_swing) as num_z_swing\n",
        "num_z_contact": ", sum(num_z_contact) as num_z_contact\n",
        "num_o_swing": ", sum(num_o_swing) as num_o_swing\n",
        "num_o_contact": ", sum(num_o_contact) as num_o_contact\n",
        "num_early_o_swing": ", sum(num_early_o_swing) as num_early_o_swing\n",
        "num_early_o_contact": ", sum(num_early_o_contact) as num_early_o_contact\n",
        "num_late_o_swing": ", sum(num_late_o_swing) as num_late_o_swing\n",
        "num_late_o_contact": ", sum(num_late_o_contact) as num_late_o_contact\n",
        "num_pulled_bip": ", sum(num_pulled_bip) as num_pulled_bip\n",
        "num_opposite_bip": ", sum(num_opposite_bip) as num_opposite_bip\n",
        "num_line_drive": ", sum(num_line_drive) as num_line_drive\n",
        "num_fly_ball": ", sum(num_fly_ball) as num_fly_ball\n",
        "num_if_fly_ball": ", sum(num_if_fly_ball) as num_if_fly_ball\n",
        "num_ground_ball": ", sum(num_ground_ball) as num_ground_ball\n",
        "num_weak_bip": ", sum(num_weak_bip) as num_weak_bip\n",
        "num_medium_bip": ", sum(num_medium_bip) as num_medium_bip\n",
        "num_hard_bip": ", sum(num_hard_bip) as num_hard_bip\n",
        "num_out": ", sum(num_outs) as num_out\n",
        "num_pa": ", sum(num_pa) as num_pa\n",
        "num_ab": ", sum(num_ab) as num_ab\n",
        "num_1b": ", sum(num_1b) as num_1b\n",
        "num_2b": ", sum(num_2b) as num_2b\n",
        "num_3b": ", sum(num_3b) as num_3b\n",
        "num_hr": ", sum(num_hr) as num_hr\n",
        "num_bb": ", sum(num_bb) as num_bb\n",
        "num_ibb": ", sum(num_ibb) as num_ibb\n",
        "num_hbp": ", sum(num_hbp) as num_hbp\n",
        "num_sacrifice": ", sum(num_sacrifice) as num_sacrifice\n",
        "num_k": ", sum(num_k) as num_k\n",
        "num_hit": ", sum(num_hit) as num_hit\n",
        "num_runs": ", sum(num_runs) as num_runs\n",
        "num_barrel": ", sum(num_barrel) as num_barrel\n",
        "total_launch_speed": ", sum(total_launch_speed) as total_launch_speed\n",
        "num_launch_speed": ", sum(num_launch_speed) as num_launch_speed\n",
        "total_launch_angle": ", sum(total_launch_angle) as total_launch_angle\n",
        "num_launch_angle": ", sum(num_launch_angle) as num_launch_angle\n",
        "total_release_extension": ", sum(total_release_extension) as total_release_extension\n",
        "num_release_extension": ", sum(num_release_extension) as num_release_extension\n",
        "total_spin_rate": ", sum(total_spin_rate) as total_spin_rate\n",
        "num_spin_rate": ", sum(num_spin_rate) as num_spin_rate\n",
        "total_x_movement": ", sum(total_x_movement) as total_x_movement\n",
        "num_x_movement": ", sum(num_x_movement) as num_x_movement\n",
        "total_z_movement": ", sum(total_z_movement) as total_z_movement\n",
        "num_z_movement": ", sum(num_z_movement) as num_z_movement\n",
        "usage_pct": ", round(100 * (sum(base.num_pitches) / nullif(pldp.num_pitches, 0)), 1) as usage_pct\n",
        "fastball_pct": ", round(100 * (sum(num_fastball) / nullif(sum(base.num_pitches), 0)), 1) as fastball_pct\n",
        "early_secondary_pct": ", round(100 * (sum(num_early_secondary) / nullif(sum(num_early), 0)), 1) as early_secondary_pct\n",
        "late_secondary_pct": ", round(100 * (sum(num_late_secondary) / nullif(sum(num_late), 0)), 1) as late_secondary_pct\n"
    }

    if leaderboard == 'pitch':
        woba_list = ['num_bb', 'num_ibb', 'num_hbp', 'num_sacrifice', 'num_1b', 'num_2b', 'num_3b', 'num_hr',
                     'num_out', 'num_hit']
    elif leaderboard == 'pitcher':
        woba_list = ['num_bb', 'num_ibb', 'num_hbp', 'num_sacrifice', 'num_1b', 'num_2b', 'num_3b', 'num_hr', 'num_ab']
    elif leaderboard == 'hitter':
        woba_list = ['num_ab', 'num_bb', 'num_ibb', 'num_hbp', 'num_sacrifice', 'num_1b', 'num_2b', 'num_3b']

    for stanza_needed in leaderboard_tabs[leaderboard][tab]:
        if stanza_needed != 'woba':
            select_query = select_query + statistic_sql_map[stanza_needed]
        elif stanza_needed == 'woba':
            for woba_variable in woba_list:
                select_query = select_query + statistic_sql_map[woba_variable]

    return select_query


def start_query_generator(home_away, year, month, half, arbitrary_start, arbitrary_end, **kwargs):
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'
    start_query = ''
    date_segment = ''
    home_away_segment = ''
    start_sub_query_select = open(sql_directory / 'start_sub_query_select.sql', 'r').read()
    start_sub_query_join = open(sql_directory / 'start_sub_query_join.sql', 'r').read()

    if arbitrary_start != 'NA' and arbitrary_end != 'NA' and arbitrary_start <= arbitrary_end:
        date_segment = "where game_played >= %s and game_played <= %s\n"
    elif year != 'NA':
        date_segment = "where year_played = %s\n"
        if month != 'NA':
            date_segment = date_segment + "and month_played = %s\n"
        elif half != 'NA':
            date_segment = date_segment + "and half_played = %s\n"

    if home_away != 'NA':
        home_away_segment = "and pitcher_home_away = %s\n"

    start_query = start_sub_query_select + date_segment + home_away_segment + start_sub_query_join
    return start_query




def create_search_query(leaderboard, handedness, opponent_handedness, league, division, team, home_away,
                        year, month, half, arbitrary_start, arbitrary_end, **kwargs):
    # Build a sql string
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'

    leaderboard_select = ''
    filter_select = ''
    base_select = ''
    post_select = ''
    date_where = ''
    filter_where = ''
    leaderboard_group_by = ''
    filter_group_by = ''
    table_select = ''

    # To-do: Make sure to join hitters and pitchers by ID after querying DB to consolidate teams
    # To-do: SQL helper to add in the pitcher aggregation subquery for the pitch type leaderboard for usage %

    print("Generating SQL at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Generating SQL at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    table_year = ''
    table = 'from pl_leaderboard_v2_daily base\n'
    if (arbitrary_start != 'NA' and arbitrary_end != 'NA') and \
            (parser.parse(arbitrary_start).year == parser.parse(arbitrary_end).year):
        table_year = parser.parse(arbitrary_start).year
    elif year != 'NA':
        table_year = year

    leaderboard_select = leaderboard_select_generator(leaderboard)

    filter_select = filter_select_generator(leaderboard, handedness, opponent_handedness, league, home_away)

    base_select = open(sql_directory / 'base_selects.sql', 'r').read()

    if leaderboard == 'pitch':
        post_select = open(sql_directory / 'pitch_post_select.sql', 'r').read()
    elif leaderboard in ['pitcher', 'hitter']:
        post_select = open(sql_directory / 'pitcher_hitter_post_select.sql', 'r').read()

    if table_year != '':
        table_select = table_select_generator(int(table_year), 'base')
    else:
        table_select = table

    date_where = date_where_generator(year, month, half, arbitrary_start, arbitrary_end, 'base')

    filter_where = filter_where_generator(leaderboard, handedness, opponent_handedness, league, division, team,
                                          home_away)

    leaderboard_group_by = leaderboard_group_by_generator(leaderboard)

    filter_group_by = filter_group_by_generator(leaderboard, handedness, opponent_handedness, league, home_away)

    if leaderboard in ['pitcher', 'hitter']:
        sql_query = leaderboard_select + filter_select + base_select + post_select + table_select + date_where + filter_where + leaderboard_group_by + filter_group_by
    elif leaderboard == 'pitch':
        join_query = pitch_aggregation_subquery_generator(handedness, opponent_handedness, league, division, team,
                                                          home_away, year, month, half, arbitrary_start, arbitrary_end)
        sql_query = leaderboard_select + filter_select + base_select + post_select + table_select + join_query + date_where + filter_where + leaderboard_group_by + filter_group_by
    else:
        logging.error("No leaderboard by {lb_name} available".format(lb_name=leaderboard))

    if sql_query == '':
        logging.error('No sql string generated')

    print(sql_query)

    print("SQL generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("SQL generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    return sql_query


def create_search_query_2_1(leaderboard, tab, handedness, opponent_handedness, league, division, team, home_away,
                            year, month, half, arbitrary_start, arbitrary_end, **kwargs):
    # Build a sql string
    sql_directory = Path.cwd() / 'leaderboard' / 'sql'

    leaderboard_select = ''
    filter_select = ''
    base_select = ''
    date_where = ''
    filter_where = ''
    leaderboard_group_by = ''
    filter_group_by = ''
    table_select = ''

    # To-do: Make sure to join hitters and pitchers by ID after querying DB to consolidate teams
    # To-do: SQL helper to add in the pitcher aggregation subquery for the pitch type leaderboard for usage %

    print("Generating SQL at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Generating SQL at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    table_year = ''
    table = 'from pl_leaderboard_v2_daily base\n'
    if (arbitrary_start != 'NA' and arbitrary_end != 'NA') and \
            (parser.parse(arbitrary_start).year == parser.parse(arbitrary_end).year):
        table_year = parser.parse(arbitrary_start).year
    elif year != 'NA':
        table_year = year

    leaderboard_select = leaderboard_select_generator(leaderboard)

    filter_select = filter_select_generator(leaderboard, handedness, opponent_handedness, league, home_away)

    base_select = select_generator(leaderboard, tab)

    if table_year != '':
        table_select = table_select_generator(int(table_year), 'base')
    else:
        table_select = table

    date_where = date_where_generator(year, month, half, arbitrary_start, arbitrary_end, 'base')

    filter_where = filter_where_generator(leaderboard, handedness, opponent_handedness, league, division, team,
                                          home_away)

    leaderboard_group_by = leaderboard_group_by_generator(leaderboard)

    filter_group_by = filter_group_by_generator(leaderboard, handedness, opponent_handedness, league, home_away)

    if leaderboard == 'hitter':
        sql_query = leaderboard_select + filter_select + base_select + table_select + date_where + filter_where + leaderboard_group_by + filter_group_by
    elif leaderboard == 'pitcher':
        start_query = start_query_generator(home_away, year, month, half, arbitrary_start, arbitrary_end)
        sql_query = leaderboard_select + filter_select + base_select + table_select + start_query + date_where + filter_where + leaderboard_group_by + filter_group_by
    elif leaderboard == 'pitch':
        join_query = pitch_aggregation_subquery_generator(handedness, opponent_handedness, league, division, team,
                                                          home_away, year, month, half, arbitrary_start, arbitrary_end)
        start_query = start_query_generator(home_away, year, month, half, arbitrary_start, arbitrary_end)
        sql_query = leaderboard_select + filter_select + base_select + table_select + join_query + start_query + date_where + filter_where + leaderboard_group_by + filter_group_by
    else:
        logging.error("No leaderboard by {lb_name} available".format(lb_name=leaderboard))

    if sql_query == '':
        logging.error('No sql string generated')

    print(sql_query)

    print("SQL generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("SQL generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    return sql_query

def create_player_query(player_id):
    print("Generating SQL at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Generating SQL at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    sql_query = ''

    table_select = 'SELECT A.mlbamid, A.playername, A.teamid, B.abbreviation AS "team", A.lastgame, A.ispitcher AS "is_pitcher", A.isactive AS "is_active", A.name_first, A.name_last, A.birth_date FROM pl_players A, teams B WHERE A.teamid=B.team_id \n'
    player_select = ''

    if player_id != 'NA':
        player_select = 'AND mlbamid = %s'

    sql_query = table_select + player_select

    if sql_query == '':
        logging.error('No sql string generated')

    print(sql_query)

    print("SQL generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("SQL generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    return sql_query

def create_player_positions_query(player_id):
    print("Generating SQL at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("Generating SQL at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    sql_query = ''

    table_select = "SELECT p.mlbamid as id, p.playername as name, json_agg(DISTINCT jsonb_build_object(pp.game_year, (SELECT json_object_agg(pp2.position, pp2.games_played) FROM pl_playerpositions pp2 WHERE pp2.mlbamid = pp.mlbamid AND pp2.game_year = pp.game_year))) as positions FROM pl_players p INNER JOIN pl_playerpositions pp USING(mlbamid)\n"
    player_select = ''
    group_by = 'GROUP BY p.mlbamid, p.playername'

    if player_id != 'NA':
        player_select = 'WHERE p.mlbamid = %s'

    sql_query = table_select + player_select + group_by

    if sql_query == '':
        logging.error('No sql string generated')

    print(sql_query)

    print("SQL generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
    logging.debug("SQL generated at {time}".format(time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

    return sql_query