from flask import current_app
from flask_restful import Resource
from cache import cache_timeout, cache_invalidate_hour
from datetime import datetime
from leaderboard import collect_leaderboard_statistics, leaderboard_collection
import logging
import json as json

class Leaderboard_2(Resource):
    @current_app.cache.cached(timeout = cache_timeout(cache_invalidate_hour()))
    def get(self, leaderboard='pitcher', handedness='NA', opponent_handedness='NA', league='NA', division='NA',
            team='NA', home_away='NA', year=datetime.now().strftime('%Y'), month='NA', half='NA', arbitrary_start='NA',
            arbitrary_end='NA'):

        raw_data = collect_leaderboard_statistics(leaderboard, handedness, opponent_handedness, league, division,
                                                   team, home_away, year, month, half, arbitrary_start, arbitrary_end)

        if leaderboard=='pitcher':
            advanced=raw_data[['player_id', 'player_name', 'player_team_abb', 'avg_velocity', 'avg_launch_speed',
                               'avg_launch_angle', 'avg_release_extension', 'avg_spin_rate', 'barrel_pct',
                               'foul_pct', 'plus_pct']]
            approach=raw_data[['player_id', 'player_name', 'player_team_abb', 'armside_pct',
                               'horizonal_middle_location_pct', 'gloveside_pct', 'high_pct',
                               'vertical_middle_location_pct', 'low_pct', 'heart_pct', 'fastball_pct',
                               'early_secondary_pct', 'late_secondary_pct', 'zone_pct', 'non_bip_strike_pct',
                               'early_bip_pct']]
            plate_discipline=raw_data[['player_id', 'player_name', 'player_team_abb', 'o_swing_pct', 'zone_pct',
                                       'swinging_strike_pct', 'called_strike_pct', 'csw_pct', 'contact_pct',
                                       'z_contact_pct', 'o_contact_pct', 'swing_pct', 'early_called_strike_pct',
                                       'late_o_swing_pct', 'f_strike_pct', 'true_f_strike_pct']]
            batted_ball=raw_data[['player_id', 'player_name', 'player_team_abb', 'groundball_pct',
                                  'linedrive_pct', 'flyball_pct', 'infield_flyball_pct', 'weak_pct',
                                  'medium_pct', 'hard_pct', 'pull_pct', 'opposite_field_pct', 'avg_launch_speed',
                                  'avg_launch_angle', 'babip_pct', 'bacon_pct']]
            overview=raw_data[['player_id', 'player_name', 'player_team_abb', 'num_ip', 'whip', 'strikeout_pct',
                               'walk_pct', 'swinging_strike_pct', 'csw_pct', 'put_away_pct', 'babip_pct',
                               'hr_flyball_pct', 'barrel_pct', 'woba']]
            standard=raw_data[['player_id', 'player_name', 'player_team_abb', 'num_pitches', 'num_hit', 'num_ip',
                               'num_hr', 'num_k', 'num_bb']]
        elif leaderboard=='hitter':
            advanced = raw_data[['player_id', 'player_name', 'player_team_abb', 'avg_launch_speed',
                                 'avg_launch_angle', 'barrel_pct', 'foul_pct', 'plus_pct', 'first_pitch_swing_pct',
                                 'early_o_contact_pct', 'late_o_contact_pct']]
            approach = raw_data[['player_id', 'player_name', 'player_team_abb', 'inside_pct',
                                 'horizonal_middle_location_pct', 'outside_pct', 'high_pct',
                                 'vertical_middle_location_pct', 'low_pct', 'heart_pct', 'fastball_pct',
                                 'early_secondary_pct', 'late_secondary_pct', 'zone_pct', 'non_bip_strike_pct',
                                 'early_bip_pct']]
            plate_discipline = raw_data[['player_id', 'player_name', 'player_team_abb', 'o_swing_pct', 'zone_pct',
                                         'swinging_strike_pct', 'called_strike_pct', 'csw_pct', 'contact_pct',
                                         'z_contact_pct', 'o_contact_pct', 'swing_pct', 'early_called_strike_pct',
                                         'late_o_swing_pct', 'f_strike_pct', 'true_f_strike_pct']]
            batted_ball = raw_data[['player_id', 'player_name', 'player_team_abb', 'groundball_pct',
                                    'linedrive_pct', 'flyball_pct', 'infield_flyball_pct', 'weak_pct',
                                    'medium_pct', 'hard_pct', 'pull_pct', 'opposite_field_pct', 'avg_launch_speed',
                                    'avg_launch_angle', 'babip_pct', 'bacon_pct']]
            overview = raw_data[['player_id', 'player_name', 'player_team_abb', 'num_pa', 'num_hr', 'batting_average',
                                 'on_base_pct', 'babip_pct', 'hr_flyball_pct', 'barrel_pct', 'swinging_strike_pct', 'woba']]
            standard = raw_data[['player_id', 'player_name', 'player_team_abb', 'num_pa', 'num_hit', 'num_1b', 'num_2b',
                                 'num_3b', 'num_hr', 'num_k', 'num_bb']]
        elif leaderboard=='pitch':
            advanced = raw_data[['player_id', 'player_name', 'player_team_abb', 'pitchtype', 'avg_velocity',
                                 'avg_launch_speed', 'avg_launch_angle', 'avg_release_extension', 'avg_spin_rate',
                                 'barrel_pct', 'avg_x_movement', 'avg_z_movement', 'plus_pct']]
            approach = raw_data[['player_id', 'player_name', 'player_team_abb', 'pitchtype', 'armside_pct',
                                 'horizonal_middle_location_pct', 'gloveside_pct', 'high_pct',
                                 'vertical_middle_location_pct', 'low_pct', 'heart_pct', 'early_pct',
                                 'behind_pct', 'late_pct', 'zone_pct', 'non_bip_strike_pct', 'early_bip_pct']]
            plate_discipline = raw_data[['player_id', 'player_name', 'player_team_abb', 'pitchtype', 'o_swing_pct',
                                         'zone_pct', 'swinging_strike_pct', 'called_strike_pct', 'csw_pct',
                                         'contact_pct','z_contact_pct', 'o_contact_pct', 'swing_pct',
                                         'early_called_strike_pct', 'late_o_swing_pct', 'f_strike_pct',
                                         'true_f_strike_pct']]
            batted_ball = raw_data[['player_id', 'player_name', 'player_team_abb', 'pitchtype', 'groundball_pct',
                                    'linedrive_pct', 'flyball_pct', 'infield_flyball_pct', 'weak_pct',
                                    'medium_pct', 'hard_pct', 'pull_pct', 'opposite_field_pct', 'avg_launch_speed',
                                    'avg_launch_angle', 'babip_pct', 'bacon_pct']]
            overview = raw_data[['player_id', 'player_name', 'player_team_abb', 'pitchtype', 'avg_velocity',
                                 'usage_pct', 'o_swing_pct', 'zone_pct', 'swinging_strike_pct', 'called_strike_pct',
                                 'csw_pct', 'put_away_pct', 'batting_average', 'woba']]
            standard = raw_data[['player_id', 'player_name', 'player_team_abb', 'pitchtype', 'num_pitches', 'num_pa',
                                 'num_hit', 'num_1b', 'num_2b', 'num_3b', 'num_hr', 'num_k', 'num_bb',
                                 'batting_average']]
        else:
            logging.error("No leaderboard of type {lb} available".format(lb=leaderboard))


        advanced_response = json.loads(advanced.to_json(orient='records', date_format='iso'))
        approach_response = json.loads(approach.to_json(orient='records', date_format='iso'))
        plate_discipline_response = json.loads(plate_discipline.to_json(orient='records', date_format='iso'))
        batted_ball_response = json.loads(batted_ball.to_json(orient='records', date_format='iso'))
        overview_response = json.loads(overview.to_json(orient='records', date_format='iso'))
        standard_response = json.loads(standard.to_json(orient='records', date_format='iso'))

        return{'advanced': advanced_response,
               'approach': approach_response,
               'plate_discipline': plate_discipline_response,
               'batted_ball': batted_ball_response,
               'overview': overview_response,
               'standard': standard_response
               }

class Leaderboard_2_1(Resource):
    @current_app.cache.cached(timeout = cache_timeout(cache_invalidate_hour()))
    def get(self, leaderboard='pitcher',tab='standard', handedness='NA', opponent_handedness='NA', league='NA', division='NA', team='NA', home_away='NA', year=datetime.now().strftime('%Y'), month='NA', half='NA', arbitrary_start='NA', arbitrary_end='NA'):

        result = leaderboard_collection(leaderboard, tab, handedness, opponent_handedness, league, division, team, home_away, year, month, half, arbitrary_start, arbitrary_end)

        json_response = json.loads(result.to_json(orient='records', date_format='iso'))
        return (json_response)
        