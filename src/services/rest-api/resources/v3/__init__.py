from flask import current_app

# legacy v3 enpoints
def init_v3_resource_endpoints():
    from .player import Player
    from .roundup import Roundup
    from .leaderboard import Leaderboard

    # v3 resource endpoints
    v3_player_routes = [
        '/v3/player/<string:query_type>/<int:player_id>/',
        '/v3/player/<string:query_type>/<int:player_id>',
        '/v3/player/<int:player_id>/',
        '/v3/player/<int:player_id>',
        '/v3/player/<string:query_type>/',
        '/v3/player/<string:query_type>',
        '/v3/player/',
        '/v3/player'
    ]
    v3_roundup_routes = [
        '/v3/roundup/<string:player_type>/<string:day>/',
        '/v3/roundup/<string:player_type>/<string:day>',
        '/v3/roundup/<string:player_type>/',
        '/v3/roundup/<string:player_type>',
        '/v3/roundup/',
        '/v3/roundup'
    ]
    v3_leaderboard_routes = [
        '/v3/leaderboard/<string:query_type>/<string:tab>/',
        '/v3/leaderboard/<string:query_type>/<string:tab>',
        '/v3/leaderboard/<string:query_type>/',
        '/v3/leaderboard/<string:query_type>',
        '/v3/leaderboard/',
        '/v3/leaderboard'
    ]

    current_app.api.add_resource(Player, *v3_player_routes, endpoint='playerv3')
    current_app.api.add_resource(Roundup, *v3_roundup_routes, endpoint='roundupv3')
    current_app.api.add_resource(Leaderboard, *v3_leaderboard_routes, endpoint='leaderboardv3')