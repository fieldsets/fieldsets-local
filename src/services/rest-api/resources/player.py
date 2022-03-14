from flask import current_app
from flask_restful import Resource
from helpers import fetch_dataframe, var_dump
from cache import cache_timeout, cache_invalidate_hour
import json as json
import pandas as pd

##
# This is the flask_restful Resource Class for the player API.
# Current Enpoint Structure:
# `/player/${query_type}/${player_id}`
# @param ${query_type}: ('bio'|'stats'|'gamelogs'|'positions'|'repertoire'|'abilities'|'locations'|'locationlogs'|'career'|'')
# @param ${player_id}: ([0-9]*|'All')
##
class Player(Resource):
    def __init__(self):
        self.player_id = 'NA'
        self.first_name = ''
        self.last_name = ''
        self.dob = ''
        self.is_pitcher = False
        self.is_hitter = False
        self.is_active = False
        self.career_stats = {}

    def get(self, query_type='NA', player_id='NA'):
        # We can have an empty query_type or player_id which return the collections of stats.
        if (query_type == 'NA' and (player_id == 'NA' or type(player_id) is int)):
            query_type = 'bio'
        elif (player_id == 'NA' and query_type.isnumeric()):
            player_id = int(query_type)
            query_type = 'bio'
        
        # Grab basic player data which tells us if we have a pitcher or hitter.
        # Also grabs career & current season stats
        if (type(player_id) is int):
            self.player_id = int(player_id)

            player_info = self.fetch_result('info', player_id)
            if player_info:
                self.first_name = player_info[0]['name_first']
                self.last_name = player_info[0]['name_last']
                self.dob = player_info[0]['birth_date']
                self.is_pitcher = bool(player_info[0]['is_pitcher'])
                self.is_active = bool(player_info[0]['is_active'])
            
            self.career_stats = self.fetch_result('career', player_id)
        
        return self.fetch_result(query_type, player_id)

    
    def fetch_result(self, query_type, player_id):
        # Caching wrapper for fetch_data
        result = None

        if (current_app.config.get('BYPASS_CACHE')):
            # Bypassing Caching of JSON Results
            result = self.fetch_data(query_type, player_id)
        else:
            # Using Cache for JSON Results
            cache_key_player_id = player_id
            cache_key_resource_type = self.__class__.__name__
            if (player_id == 'NA'):
                cache_key_player_id = 'all'

            cache_key = f'{cache_key_resource_type}-{query_type}-{cache_key_player_id}'
            result = current_app.cache.get(cache_key)
            if (result is None):
                result = self.fetch_data(query_type, player_id)
                current_app.cache.set(cache_key, result,cache_timeout(cache_invalidate_hour()))

        return result

    def fetch_data(self, query_type, player_id):
        query = self.get_query(query_type, player_id)
        query_var=None
        if (type(player_id) is int):
            query_var = player_id

        raw = fetch_dataframe(query,query_var)
        results = self.format_results(query_type, raw)
        output = self.get_json(query_type,player_id,results)

        return output

    def get_query(self, query_type, player_id):
        def default():
            return f"SELECT 'query not defined' AS error, '{query_type}' AS query, {player_id} AS id;"

        def abilities():
            if (self.is_pitcher):
                return (
                    f'SELECT pitchermlbamid,'
                        f'year::text,'
                        f'g::int,'
                        f'ip,'
                        f'batting_average_percentile,'
                        f'hr_9_percentile,'
                        f'era_percentile,'
                        f'k_pct_percentile,'
                        f'bb_pct_percentile,'
                        f'whip_pct_percentile,'
                        f'csw_pct_percentile,'
                        f'o_swing_pct_percentile,'
                        f'babip_pct_percentile,'
                        f'hr_fb_rate_percentile,'
                        f'lob_pct_percentile,'
                        f'flyball_pct_percentile,'
                        f'groundball_pct_percentile,'
                        f'woba_rhb_percentile,'
                        f'woba_lhb_percentile,'
                        f'swinging_strike_pct_percentile,'
                        f'called_strike_pct_percentile,'
                        f'hbp_percentile,'
                        f'batting_average_risp_percentile,'
                        f'batting_average_no_runners,'
                        f'ips_percentile,'
                        f'true_f_strike_pct_percentile '
                    f'FROM mv_pitcher_percentiles '
                    f'WHERE pitchermlbamid = %s;'
                )
            else:
                return (
                    f'SELECT hittermlbamid,'
                        f'year, '
                        f'pa, '
                        f'batting_average_percentile, '
                        f'hr_pa_rate_percentile, '
                        f'r_percentile, '
                        f'rbi_percentile, '
                        f'k_pct_percentile, '
                        f'bb_pct_percentile, '
                        f'sb_percentile, '
                        f'cs_percentile, '
                        f'o_swing_pct_percentile, '
                        f'babip_pct_percentile, '
                        f'flyball_pct_percentile, '
                        f'linedrive_pct_percentile, '
                        f'groundball_pct_percentile, '
                        f'woba_rhb_percentile, '
                        f'woba_lhb_percentile, '
                        f'swinging_strike_pct_percentile, '
                        f'hbp_percentile, '
                        f'triples_percentile, '
                        f'doubles_percentile, '
                        f'ops_percentile, '
                        f'pull_pct_percentile, '
                        f'oppo_pct_percentile, '
                        f'swing_pct_percentile, '
                        f'obp_pct_percentile '
                    f'FROM mv_hitter_percentiles '
                    f'WHERE hittermlbamid = %s;'
                )
        
        def bio():
            sql_query = ''

            table_select = 'SELECT A.mlbamid, A.playername, A.teamid, B.abbreviation AS "team", A.lastgame, A.ispitcher AS "is_pitcher", A.isactive AS "is_active", A.name_first, A.name_last, A.birth_date FROM pl_players A, teams B WHERE A.teamid=B.team_id \n'
            player_select = ''

            if player_id != 'NA':
                player_select = 'AND mlbamid = %s'

            sql_query = table_select + player_select

            return sql_query

        def career():
            if (self.is_pitcher):
                return (
                    f'SELECT year::text AS "year", '
                        f'g::int, '
                        f'gs::int, '
                        f'w::int, '
                        f'l::int, '
                        f'sv::int, '
                        f'hld::int, '
                        f'ip, '
                        f'cg::int, '
                        f'sho::int, '
                        f'runs::int, '
                        f'unearned_runs::int, '
                        f'earned_runs::int, '
                        f'era, '
                        f'whip, '
                        f'lob_pct, '
                        f'k_pct, '
                        f'bb_pct, '
                        f'hr_flyball_pct, '
                        f'hbp::int, '
                        f'wp::int, '
                        f'teams '
                    f'FROM mv_pitcher_career_stats '
                    f'WHERE pitchermlbamid = %s '
                    f'ORDER BY year ASC;'
                )
            else:
                return (
                    f'SELECT year::text AS "year", '
                        f'g::int,'
                        f'runs::int, '
                        f'rbi::int, '
                        f'sb::int, '
                        f'cs::int, '
                        f'teams '
                    f'FROM mv_hitter_career_stats '
                    f'WHERE hittermlbamid = %s '
                    f'ORDER BY year ASC;'
                )

        def gamelogs():
            if (self.is_pitcher):
                return (
                    f'SELECT ghuid AS "gameid",'
                    f'game_played AS "game-date",'
                    f'team,'
                    f'thrown_for_team::int AS "team-id",'
                    f'opponent,'
                    f'thrown_against_team::int AS "opponent-team-id",'
                    f'park,'
                    f'team_result AS "team-result",'
                    f'runs_scored::int AS "runs-scored",'
                    f'opponent_runs_scored::int AS "opponent-runs-scored",'
                    f'start::int AS "gs",'
                    f'win::int AS "w",'
                    f'loss::int AS "l",'
                    f'save::int AS "sv",'
                    f'hold::int AS "hld",'
                    f'num_ip AS "ip",'
                    f'num_runs::int AS "runs",'
                    f'num_earned_runs::int AS "earned_runs",'
                    f'lob::int,'
                    f'lob_pct,'
                    f'pitchtype,'
                    f'opponent_handedness AS "split-RL",'
                    f'avg_velocity AS "velo_avg",'
                    f'strikeout_pct,'
                    f'bb_pct,'
                    f'usage_pct,'
                    f'batting_average AS "batting_avg",' 
                    f'o_swing_pct,'
                    f'z_swing_pct,'
                    f'zone_pct,'
                    f'swinging_strike_pct,'
                    f'called_strike_pct,'
                    f'csw_pct,'
                    f'cswf_pct,'
                    f'plus_pct,'
                    f'foul_pct,'
                    f'contact_pct,'
                    f'o_contact_pct,'
                    f'z_contact_pct,'
                    f'swing_pct,'
                    f'strike_pct,'
                    f'early_called_strike_pct,'
                    f'late_o_swing_pct,'
                    f'f_strike_pct,'
                    f'true_f_strike_pct,'
                    f'groundball_pct,'
                    f'linedrive_pct,'
                    f'flyball_pct,'
                    f'hr_flyball_pct,'
                    f'groundball_flyball_pct,'
                    f'infield_flyball_pct,'
                    f'weak_pct,'
                    f'medium_pct,'
                    f'hard_pct,'
                    f'center_pct,'
                    f'pull_pct,'
                    f'opposite_field_pct,'
                    f'babip_pct,'
                    f'bacon_pct,'
                    f'armside_pct,'
                    f'gloveside_pct,'
                    f'vertical_middle_location_pct AS "v_mid_pct",'
                    f'horizonal_middle_location_pct AS "h_mid_pct",'
                    f'high_pct,'
                    f'low_pct,'
                    f'heart_pct,'
                    f'early_pct,'
                    f'behind_pct,'
                    f'late_pct,'
                    f'non_bip_strike_pct,'
                    f'early_bip_pct,'
                    f'num_pitches::int AS "pitch-count",'
                    f'num_hit::int AS "hits",'
                    f'num_bb::int AS "bb",'
                    f'num_1b::int AS "1b",' 
                    f'num_2b::int AS "2b",' 
                    f'num_3b::int AS "3b",' 
                    f'num_hr::int AS "hr",' 
                    f'num_k::int AS "k",'
                    f'num_pa::int AS "pa",'
                    f'num_strikes::int AS "strikes",' 
                    f'num_balls::int AS "balls",' 
                    f'num_foul::int AS "foul",' 
                    f'num_ibb::int AS "ibb",'
                    f'num_hbp::int AS "hbp",' 
                    f'num_wp::int AS "wp",'
                    f'num_flyball::int as "flyball",'
                    f'num_whiff::int as "whiff",'
                    f'num_zone::int as "zone",'
                    f'total_velo,'
                    f'num_velo::int as "pitches-clocked",'
                    f'num_armside::int as "armside",'
                    f'num_gloveside::int as "gloveside",'
                    f'null::int as "inside",'
                    f'null::int as "outside",'
                    f'num_horizontal_middle::int as "h-mid",'
                    f'num_high::int as "high",'
                    f'num_middle::int as "mid",'
                    f'num_low::int as "low",'
                    f'num_heart::int as "heart",'
                    f'num_early::int as "early",'
                    f'num_late::int as "late",'
                    f'num_behind::int as "behind",'
                    f'num_non_bip_strike::int as "non-bip-strike",'
                    f'num_batted_ball_event::int as "batted-ball-event",'
                    f'num_early_bip::int as "early-bip",'
                    f'null::int as "fastball",'
                    f'null::int as "secondary",'
                    f'null::int as "early-secondary",'
                    f'null::int as "late-secondary",'
                    f'num_called_strike::int as "called-strike",'
                    f'num_early_called_strike::int as "early-called-strike",'
                    f'null::int as "putaway",'
                    f'num_swing::int as "swings",'
                    f'num_contact::int as "contact",'
                    f'num_first_pitch_swing::int as "first-pitch-swings",'
                    f'num_first_pitch_strike::int "first-pitch-strikes",'
                    f'num_true_first_pitch_strike::int as "true-first-pitch-strikes",'
                    f'num_plus_pitch::int as "plus-pitch",'
                    f'num_z_swing::int as "z-swing",'
                    f'num_z_contact::int as "z-contact",'
                    f'num_o_swing::int as "o-swing",'
                    f'num_o_contact::int as "o-contact",'
                    f'null::int as "early-o-swing",'
                    f'null::int as "early-o-contact",'
                    f'num_late_o_swing::int as "late-o-swing",'
                    f'num_late_o_contact::int as "late-o-contact",'
                    f'num_pulled_bip::int as "pulled-bip",'
                    f'num_opposite_bip::int as "opp-bip",'
                    f'num_line_drive::int as "line-drive",'
                    f'num_if_fly_ball::int as "if-flyball",'
                    f'num_ground_ball::int as "groundball",'
                    f'num_weak_bip::int as "weak-bip",'
                    f'num_medium_bip::int "medium-bip",'
                    f'num_hard_bip::int as "hard-bip",'
                    f'num_ab::int as "ab" '
                f'FROM mv_pitcher_game_logs_2 '
                f'WHERE pitchermlbamid=%s ' 
                f'ORDER BY year_played DESC, month_played DESC, ghuid DESC;'
                )
            else:
                return (
                    f'SELECT ghuid AS "gameid",'
                        f'game_played AS "game-date",'
                        f'team,'
                        f'teamid::int AS "team-id",'
                        f'opponent,'
                        f'opponentteamid::int AS "opponent-team-id",'
                        f'park,'
                        f'team_result AS "team-result",'
                        f'runs_scored::int AS "runs-scored",'
                        f'opponent_runs_scored::int AS "opponent-runs-scored",'
                        f'num_runs::int AS "runs",'
                        f'pitchtype,'
                        f'opponent_handedness AS "split-RL",'
                        f'avg_velocity AS "velo_avg",'
                        f'strikeout_pct,'
                        f'bb_pct,'
                        f'usage_pct,'
                        f'batting_average AS "batting_avg",' 
                        f'o_swing_pct,'
                        f'null::numeric as z_swing_pct,'
                        f'zone_pct,'
                        f'swinging_strike_pct,'
                        f'called_strike_pct,'
                        f'csw_pct,'
                        f'cswf_pct,'
                        f'plus_pct,'
                        f'foul_pct,'
                        f'contact_pct,'
                        f'o_contact_pct,'
                        f'z_contact_pct,'
                        f'swing_pct,'
                        f'strike_pct,'
                        f'early_called_strike_pct,'
                        f'late_o_swing_pct,'
                        f'f_strike_pct,'
                        f'true_f_strike_pct,'
                        f'groundball_pct,'
                        f'linedrive_pct,'
                        f'flyball_pct,'
                        f'hr_flyball_pct,'
                        f'groundball_flyball_pct,'
                        f'infield_flyball_pct,'
                        f'weak_pct,'
                        f'medium_pct,'
                        f'hard_pct,'
                        f'center_pct,'
                        f'pull_pct,'
                        f'opposite_field_pct,'
                        f'babip_pct,'
                        f'bacon_pct,'
                        f'armside_pct,'
                        f'gloveside_pct,'
                        f'vertical_middle_location_pct AS "v_mid_pct",'
                        f'horizonal_middle_location_pct AS "h_mid_pct",'
                        f'high_pct,'
                        f'low_pct,'
                        f'heart_pct,'
                        f'early_pct,'
                        f'behind_pct,'
                        f'late_pct,'
                        f'non_bip_strike_pct,'
                        f'early_bip_pct,'
                        f'num_pitches::int AS "pitch-count",'
                        f'num_sb::int AS "sb",'
                        f'num_cs::int AS "cs",'
                        f'num_hit::int AS "hits",'
                        f'num_bb::int AS "bb",'
                        f'num_1b::int AS "1b",' 
                        f'num_2b::int AS "2b",' 
                        f'num_3b::int AS "3b",' 
                        f'num_hr::int AS "hr",' 
                        f'num_k::int AS "k",'
                        f'num_pa::int AS "pa",'
                        f'num_strikes::int AS "strikes",' 
                        f'num_balls::int AS "balls",' 
                        f'num_foul::int AS "foul",' 
                        f'num_ibb::int AS "ibb",' 
                        f'num_hbp::int AS "hbp",' 
                        f'num_flyball::int as "flyball",'
                        f'num_whiff::int as "whiff",'
                        f'num_zone::int as "zone",'
                        f'total_velo,'
                        f'num_velo::int as "pitches-clocked",'
                        f'num_armside::int as "armside",'
                        f'num_gloveside::int as "gloveside",'
                        f'null::int as "inside",'
                        f'null::int as "outside",'
                        f'num_horizontal_middle::int as "h-mid",'
                        f'num_high::int as "high",'
                        f'num_middle::int as "mid",'
                        f'num_low::int as "low",'
                        f'num_heart::int as "heart",'
                        f'num_early::int as "early",'
                        f'num_late::int as "late",'
                        f'num_behind::int as "behind",'
                        f'num_non_bip_strike::int as "non-bip-strike",'
                        f'num_batted_ball_event::int as "batted-ball-event",'
                        f'num_early_bip::int as "early-bip",'
                        f'null::int as "fastball",'
                        f'null::int as "secondary",'
                        f'null::int as "early-secondary",'
                        f'null::int as "late-secondary",'
                        f'num_called_strike::int as "called-strike",'
                        f'num_early_called_strike::int as "early-called-strike",'
                        f'null::int as "putaway",'
                        f'num_swing::int as "swings",'
                        f'num_contact::int as "contact",'
                        f'num_first_pitch_swing::int as "first-pitch-swings",'
                        f'num_first_pitch_strike::int "first-pitch-strikes",'
                        f'num_true_first_pitch_strike::int as "true-first-pitch-strikes",'
                        f'num_plus_pitch::int as "plus-pitch",'
                        f'num_z_swing::int as "z-swing",'
                        f'num_z_contact::int as "z-contact",'
                        f'num_o_swing::int as "o-swing",'
                        f'num_o_contact::int as "o-contact",'
                        f'null::int as "early-o-swing",'
                        f'null::int as "early-o-contact",'
                        f'num_late_o_swing::int as "late-o-swing",'
                        f'num_late_o_contact::int as "late-o-contact",'
                        f'num_pulled_bip::int as "pulled-bip",'
                        f'num_opposite_bip::int as "opp-bip",'
                        f'num_line_drive::int as "line-drive",'
                        f'num_if_fly_ball::int as "if-flyball",'
                        f'num_ground_ball::int as "groundball",'
                        f'num_weak_bip::int as "weak-bip",'
                        f'num_medium_bip::int "medium-bip",'
                        f'num_ab::int as "ab",'
                        f'num_hard_bip::int as "hard-bip",'
                        f'num_rbi AS "rbi",'
                        f'ops_pct AS "ops" '
                    f'FROM mv_hitter_game_logs_2 '
                    f'WHERE hittermlbamid=%s and game_played >= current_date - interval \'400 day\'' 
                    f'ORDER BY year_played DESC, month_played DESC, ghuid DESC;'
                )

        def info():
            return (
                f'SELECT name_first,'
                    f'name_last,'
                    f'birth_date,'
                    f'ispitcher AS "is_pitcher",'
                    f'isactive AS "is_active" '
                f'FROM pl_players '
                f'WHERE mlbamid=%s;'
            )

        def locationlogs():
            if (self.is_pitcher):
                return (
                    f'SELECT DISTINCT ghuid AS "gameid",'
                        f'pitchtype,'
                        f'hitterside AS "split-RL",'
                        f'pitch_locations, '
                        f'num_pitches AS "pitch-count", '
                        f'usage_pct, '
                        f'whiff, '
                        f'called_strike, '
                        f'csw_pct, '
                        f'zone_pct, '
                        f'zone_swing_pct, '
                        f'swinging_strike_pct, '
                        f'o_swing_pct, '
                        f'avg_velocity '
                    f'FROM mv_pitcher_game_log_pitches '
                    f"WHERE pitchermlbamid = %s "
                    f'ORDER BY ghuid;'
                )
            else:
                return (
                    f'SELECT DISTINCT ghuid AS "gameid",'
                        f'pitchtype,'
                        f'pitcherside AS "split-RL",'
                        f'pitch_locations, '
                        f'num_pitches AS "pitch-count", '
                        f'usage_pct, '
                        f'whiff, '
                        f'called_strike, '
                        f'csw_pct, '
                        f'zone_pct, '
                        f'zone_swing_pct, '
                        f'swinging_strike_pct, '
                        f'o_swing_pct, '
                        f'avg_velocity '
                    f'FROM mv_hitter_game_log_pitches '
                    f"WHERE hittermlbamid = %s "
                    f'ORDER BY ghuid;'
                )

        def locations():
            return(
                f'SELECT pitchtype,' 
                    f'year_played AS "year",' 
                    f'opponent_handedness AS "split-RL",'
                    f'home_away AS "split-HA",'
                    f'pitch_locations '
                f'FROM player_page_repertoire '
                f"WHERE pitchermlbamid = %s "
                f"AND pitchtype <> 'All' AND year_played <> 'All' "
                f'ORDER BY pitchtype, year_played, opponent_handedness, home_away;'
            )

        def positions():
            table_select = "SELECT p.mlbamid as id, p.playername as name, json_agg(DISTINCT jsonb_build_object(pp.game_year, (SELECT json_object_agg(pp2.position, pp2.games_played) FROM pl_playerpositions pp2 WHERE pp2.mlbamid = pp.mlbamid AND pp2.game_year = pp.game_year))) as positions FROM pl_players p INNER JOIN pl_playerpositions pp USING(mlbamid)\n"
            player_select = ''
            group_by = 'GROUP BY p.mlbamid, p.playername'

            if player_id != 'NA':
                player_select = 'WHERE p.mlbamid = %s'

            sql_query = table_select + player_select + group_by

            return sql_query

        def stats():
            if (self.is_pitcher):
                return (
                    f'SELECT pitchtype,' 
                        f'year_played::text AS "year",' 
                        f'opponent_handedness AS "split-RL",'
                        f'home_away AS "split-HA",'
                        f'avg_velocity AS "velo_avg",'
                        f'k_pct,'
                        f'bb_pct,'
                        f'usage_pct,'
                        f'batting_average AS "batting_avg",' 
                        f'o_swing_pct,'
                        f'zone_pct,'
                        f'swinging_strike_pct,'
                        f'called_strike_pct,'
                        f'csw_pct,'
                        f'cswf_pct,'
                        f'plus_pct,'
                        f'foul_pct,'
                        f'contact_pct,'
                        f'o_contact_pct,'
                        f'z_contact_pct,'
                        f'swing_pct,'
                        f'strike_pct,'
                        f'early_called_strike_pct,'
                        f'late_o_swing_pct,'
                        f'f_strike_pct,'
                        f'true_f_strike_pct,'
                        f'groundball_pct,'
                        f'linedrive_pct,'
                        f'flyball_pct,'
                        f'hr_flyball_pct,'
                        f'groundball_flyball_pct,'
                        f'infield_flyball_pct,'
                        f'weak_pct,'
                        f'medium_pct,'
                        f'hard_pct,'
                        f'center_pct,'
                        f'pull_pct,'
                        f'opposite_field_pct,'
                        f'babip_pct,'
                        f'bacon_pct,'
                        f'armside_pct,'
                        f'gloveside_pct,'
                        f'vertical_middle_location_pct AS "v_mid_pct",'
                        f'horizonal_middle_location_pct AS "h_mid_pct",'
                        f'high_pct,'
                        f'low_pct,'
                        f'heart_pct,'
                        f'early_pct,'
                        f'behind_pct,'
                        f'late_pct,'
                        f'non_bip_strike_pct,'
                        f'early_bip_pct,'
                        f'num_pitches::int AS "pitch-count", num_hits::int AS "hits", num_bb::int AS "bb", num_1b::int AS "1b", num_2b::int AS "2b", num_3b::int AS "3b", num_hr::int AS "hr", num_k::int AS "k",num_pa::int AS "pa",num_strike::int AS "strikes", num_ball::int AS "balls", num_foul::int AS "foul", num_ibb::int AS "ibb", num_hbp::int AS "hbp", num_wp::int AS "wp" '
                    f'FROM player_page_repertoire '
                    f"WHERE pitchermlbamid = %s "
                    f'ORDER BY pitchtype, year_played, opponent_handedness, home_away;'
                )
            else:
                return (
                    f'SELECT year_played AS "year",' 
                        f'opponent_handedness AS "split-RL",'
                        f'home_away AS "split-HA",'
                        f'avg_velocity AS "velo_avg",'
                        f'k_pct,'
                        f'bb_pct,'
                        f'batting_average AS "batting_avg",'
                        f'o_swing_pct,'
                        f'zone_pct,'
                        f'swinging_strike_pct,'
                        f'called_strike_pct,'
                        f'csw_pct,'
                        f'cswf_pct,'
                        f'plus_pct,'
                        f'foul_pct,'
                        f'contact_pct,'
                        f'o_contact_pct,'
                        f'z_contact_pct,'
                        f'swing_pct,'
                        f'strike_pct,'
                        f'early_called_strike_pct,'
                        f'late_o_swing_pct,'
                        f'f_strike_pct,'
                        f'true_f_strike_pct,'
                        f'groundball_pct,'
                        f'linedrive_pct,'
                        f'flyball_pct,'
                        f'hr_flyball_pct,'
                        f'groundball_flyball_pct,'
                        f'infield_flyball_pct,'
                        f'weak_pct,'
                        f'medium_pct,'
                        f'hard_pct,'
                        f'center_pct,'
                        f'pull_pct,'
                        f'opposite_field_pct,'
                        f'babip_pct,'
                        f'bacon_pct,'
                        f'armside_pct,'
                        f'gloveside_pct,'
                        f'vertical_middle_location_pct AS "v_mid_pct",'
                        f'horizonal_middle_location_pct AS "h_mid_pct",'
                        f'high_pct,'
                        f'low_pct,'
                        f'heart_pct,'
                        f'early_pct,'
                        f'behind_pct,'
                        f'late_pct,'
                        f'non_bip_strike_pct,'
                        f'early_bip_pct,'
                        f'onbase_pct,'
                        f'ops_pct,'
                        f'null::int AS "wob_avg",'
                        f'early_o_contact_pct,'
                        f'late_o_contact_pct,'
                        f'first_pitch_swing_pct,'
                        f'num_pitches AS "pitch-count",'
                        f'num_hits AS "hits",' 
                        f'num_bb AS "bb",' 
                        f'num_1b AS "1b",' 
                        f'num_2b AS "2b",' 
                        f'num_3b AS "3b",' 
                        f'num_hr AS "hr",'
                        f'num_k AS "k",'
                        f'num_pa AS "pa",'
                        f'num_strike AS "strikes",' 
                        f'num_ball AS "balls",' 
                        f'null::int AS "foul",' 
                        f'null::int AS "ibb",' 
                        f'null::int AS "hbp",'
                        f'num_rbi AS "rbi" '
                    f'FROM mv_hitter_page_stats '
                    f"WHERE hittermlbamid = %s "
                    f'ORDER BY year_played, opponent_handedness, home_away; '
                )

        queries = {
            "abilities": abilities,
            "bio": bio,
            "career": career,
            "gamelogs": gamelogs,
            "info": info,
            "locationlogs": locationlogs,
            "locations": locations,
            "positions": positions,
            "repertoire": stats,
            "stats": stats
        }

        return queries.get(query_type, default)()

    def format_results(self, query_type, data):

        def default():
            return data

        def career():
            if (self.is_pitcher):
                data['ip'] = pd.to_numeric(data['ip'], downcast='integer')
                data[['g','gs','w','l','sv','hld','cg','sho']] = data[['g','gs','w','l','sv','hld','cg','sho']].apply(pd.to_numeric,downcast='integer')

            formatted_data = data.set_index(['year'])
            return formatted_data

        def locationlogs():
            formatted_results = data.set_index(['gameid','pitchtype','split-RL'])
            
            return formatted_results
        
        def gamelogs():
            formatted_data = data.set_index(['gameid','pitchtype','split-RL'])
            return formatted_data

        def stats():
            if (self.is_pitcher):
                formatted_results = data.set_index(['pitchtype','year','split-RL','split-HA'])
            else:
                formatted_results = data.set_index(['year','split-RL','split-HA'])

            return formatted_results

        formatting = {
            "career": career,
            "gamelogs": gamelogs,
            "locationlogs": locationlogs,
            "locations": stats,
            "repertoire": stats,
            "stats": stats
        }

        return formatting.get(query_type, default)()
    
    def get_json(self, query_type, player_id, results):
        
        def default():
            # Ensure we have valid data for NaN entries using json.dumps of Python None object
            results.fillna(value=json.dumps(None), inplace=True)
            
            # Allow date formatting to_json instead of to_dict. Convert back to dict with json.loads
            return json.loads(results.to_json(orient='records', date_format='iso'))

        def bio():
            # Ensure we have valid data for NaN entries using json.dumps of Python None object
            results['lastgame'] = pd.to_datetime(results['lastgame']).dt.strftime("%a %m/%d/%Y")
            results['birth_date'] = pd.to_datetime(results['birth_date']).dt.strftime("%a %m/%d/%Y")
            results.fillna(value=json.dumps(None), inplace=True)

            # Allow date formatting to_json instead of to_dict. Convert back to dict with json.loads
            return json.loads(results.to_json(orient='records', date_format='iso'))
        
        def career():
            results.fillna(value=0, inplace=True)            
            output = json.loads(results.to_json(orient='index'))
            
            return output

        def gamelogs():
            results.fillna(value=0, inplace=True)

            # Functionality Removed.
            # Set up columnar data for local browser storage and filters
            # Front end can quickly slice on lookup of index in game_id_index data hash
            # hits = results['hits'].to_numpy(dtype=int,copy=True,na_value=0).tolist()

            # Convert datetime to usable json format
            results['game-date'] = pd.to_datetime(results['game-date']).dt.strftime("%a %m/%d/%Y")

            output_dict = { 'player_id': player_id, 'is_pitcher': self.is_pitcher, 'is_active': self.is_active, 'logs': {} }

            # Ensure we have valid data for NaN entries using json.dumps of Python None object
            result_dict = json.loads(results.to_json(orient='index'))
            
            if (self.is_pitcher):

                # Drop cols that are not displayed on the front end
                # TODO: Add cols here that can safely be dropped as they are not used on the frontend.
                #results.drop(columns=['start','sac','csw'], inplace=True)

                for keys, value in result_dict.items():

                    # json coversion returns tuple string
                    key = eval(keys)
                    gameid_key = key[0]
                    if gameid_key not in output_dict['logs']:
                        output_dict['logs'][gameid_key] = { 'game': {
                            'gs': value['gs'], 
                            'w': value['w'], 
                            'l': value['l'], 
                            'sv': value['sv'],
                            'hld': value['hld'],
                            'ip': value['ip'],
                            'r': value['runs'],
                            'er': value['earned_runs'],
                            'lob': value['lob'],
                            'lob_pct': value['lob_pct'],
                            'park': value['park'],
                            'team-id': value['team-id'],
                            'team': value['team'],
                            'opponent-team-id': value['opponent-team-id'],
                            'opponent': value['opponent'],
                            'game-date': value['game-date'],
                            'team-result': value['team-result'],
                            'runs-scored': value['runs-scored'],
                            'opponent-runs-scored': value['opponent-runs-scored']
                        }, 'pitches':{}}
                    
                    # Delete keys from value dict
                    del value['gs']
                    del value['park']
                    del value['team-id']
                    del value['team']
                    del value['opponent-team-id']
                    del value['opponent']
                    del value['game-date']
                    del value['team-result']
                    del value['runs-scored']
                    del value['opponent-runs-scored']

                    pitch_key = key[1].upper()

                    if pitch_key not in output_dict['logs'][gameid_key]['pitches']:
                        output_dict['logs'][gameid_key]['pitches'][pitch_key] = {'splits':{}}
                    
                    rl_split_key = key[2].upper()
                    if rl_split_key not in output_dict['logs'][gameid_key]['pitches'][pitch_key]['splits']:
                        output_dict['logs'][gameid_key]['pitches'][pitch_key]['splits'][rl_split_key] = value
                
                return output_dict

            else:
                for keys, value in result_dict.items():

                    # json coversion returns tuple string
                    key = eval(keys)
                    gameid_key = key[0]
                    if gameid_key not in output_dict['logs']:
                        output_dict['logs'][gameid_key] = { 'game': {
                            'r': value['runs'],
                            'park': value['park'],
                            'team-id': value['team-id'],
                            'team': value['team'],
                            'opponent-team-id': value['opponent-team-id'],
                            'opponent': value['opponent'],
                            'game-date': value['game-date'],
                            'team-result': value['team-result'],
                            'runs-scored': value['runs-scored'],
                            'opponent-runs-scored': value['opponent-runs-scored']
                        }, 'pitches':{}}
                    
                    # Delete keys from value dict
                    del value['runs']
                    del value['park']
                    del value['team-id']
                    del value['team']
                    del value['opponent-team-id']
                    del value['opponent']
                    del value['game-date']
                    del value['team-result']
                    del value['runs-scored']
                    del value['opponent-runs-scored']

                    pitch_key = key[1].upper()

                    if pitch_key not in output_dict['logs'][gameid_key]['pitches']:
                        output_dict['logs'][gameid_key]['pitches'][pitch_key] = {'splits':{}}
                    
                    rl_split_key = key[2].upper()
                    if rl_split_key not in output_dict['logs'][gameid_key]['pitches'][pitch_key]['splits']:
                        output_dict['logs'][gameid_key]['pitches'][pitch_key]['splits'][rl_split_key] = value
                
                return output_dict
                
        def locationlogs():
            output_dict = { 'player_id': player_id, 'is_pitcher': self.is_pitcher, 'is_active': self.is_active, 'logs': {} }
            results.fillna(value=0, inplace=True)
            result_dict = json.loads(results.to_json(orient='index'))
            
            for keys, value in result_dict.items():
                # json coversion returns tuple string
                key = eval(keys)
                gameid_key = key[0]
                if gameid_key not in output_dict['logs']:
                    output_dict['logs'][gameid_key] = {'pitches':{}}

                pitch_key = key[1].upper()

                if pitch_key not in output_dict['logs'][gameid_key]['pitches']:
                    output_dict['logs'][gameid_key]['pitches'][pitch_key] = {'splits':{}}
                
                rl_split_key = key[2].upper()
                if rl_split_key not in output_dict['logs'][gameid_key]['pitches'][pitch_key]['splits']:
                    output_dict['logs'][gameid_key]['pitches'][pitch_key]['splits'][rl_split_key] = value
            
            return output_dict

        def stats():
            # Ensure we have valid data for NaN entries using json.dumps of Python None object
            results.fillna(value=json.dumps(None), inplace=True)

            result_dict = json.loads(results.to_json(orient='index'))

            if (self.is_pitcher):
                # Sort our DataFrame so we have a prettier JSON format for the API
                output_dict = { 'player_id': player_id, 'is_pitcher': self.is_pitcher, 'is_active': self.is_active, query_type: {'pitches':{}} }

                # Make sure our index keys exist in our dict structure then push on our data values
                for keys, value in result_dict.items():
                    # json coversion returns tuple string
                    key = eval(keys)
                    pitch_key = key[0].upper()

                    if pitch_key not in output_dict[query_type]['pitches']:
                        output_dict[query_type]['pitches'][pitch_key] = {'years':{}}

                    year_key = key[1]
                    stats = { 'total': self.career_stats[year_key], 'splits':{} } if (pitch_key == 'ALL') else { 'splits':{} }
                    if year_key not in output_dict[query_type]['pitches'][pitch_key]['years']:
                        output_dict[query_type]['pitches'][pitch_key]['years'][year_key] = stats
                    
                    rl_split_key = key[2].upper()
                    if rl_split_key not in output_dict[query_type]['pitches'][pitch_key]['years'][year_key]['splits']:
                        output_dict[query_type]['pitches'][pitch_key]['years'][year_key]['splits'][rl_split_key] = {'park':{}}
                
                    ha_split_key = key[3].upper() if (key[3] == 'All') else key[3]
                    output_dict[query_type]['pitches'][pitch_key]['years'][year_key]['splits'][rl_split_key]['park'][ha_split_key] = value
            else:
                # Sort our DataFrame so we have a prettier JSON format for the API
                output_dict = { 'player_id': player_id, 'is_pitcher': self.is_pitcher, 'is_active': self.is_active, query_type: {'years':{}} }

                # Make sure our index keys exist in our dict structure then push on our data values
                for keys, value in result_dict.items():
                    # json coversion returns tuple string
                    key = eval(keys)

                    year_key = key[0]
                    stats = { 'total': self.career_stats[year_key], 'splits':{} }
                    if year_key not in output_dict[query_type]['years']:
                        output_dict[query_type]['years'][year_key] = stats
                    
                    rl_split_key = key[1].upper()
                    if rl_split_key not in output_dict[query_type]['years'][year_key]['splits']:
                        output_dict[query_type]['years'][year_key]['splits'][rl_split_key] = {'park':{}}
                
                    ha_split_key = key[2]
                    output_dict[query_type]['years'][year_key]['splits'][rl_split_key]['park'][ha_split_key] = value
            
            return output_dict

        json_data = {
            "bio": bio,
            "career": career,
            "gamelogs": gamelogs,
            "locationlogs": locationlogs,
            "locations": stats,
            "stats": stats,
            "repertoire": stats
        }

        return json_data.get(query_type, default)()
