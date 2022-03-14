from flask import current_app

# Endpoints for current corresponding Resources found in `/resources/`
def init_resource_endpoints():
    # Import after current app has been setup to use @current_app.cache.cached decorator
    from .player import Player
    from .roundup import Roundup
    from .leaderboard import Leaderboard
    from .util import Status, ClearCache

    # Legacy Instantiators
    from .v1 import init_v1_resource_endpoints
    from .v2 import init_v2_resource_endpoints
    from .v3 import init_v3_resource_endpoints

    # Legacy Endpoints
    init_v1_resource_endpoints()
    init_v2_resource_endpoints()
    init_v3_resource_endpoints()

    # v4 resource endpoints
    v4_player_routes = [
        '/v4/player/<string:query_type>/<int:player_id>/',
        '/v4/player/<string:query_type>/<int:player_id>',
        '/v4/player/<int:player_id>/',
        '/v4/player/<int:player_id>',
        '/v4/player/<string:query_type>/',
        '/v4/player/<string:query_type>',
        '/v4/player/',
        '/v4/player'
    ]
    v4_roundup_routes = [
        '/v4/roundup/<string:player_type>/<string:day>/',
        '/v4/roundup/<string:player_type>/<string:day>',
        '/v4/roundup/<string:player_type>/',
        '/v4/roundup/<string:player_type>',
        '/v4/roundup/',
        '/v4/roundup'
    ]
    v4_leaderboard_routes = [
        '/v4/leaderboard/<string:query_type>/<string:tab>/',
        '/v4/leaderboard/<string:query_type>/<string:tab>',
        '/v4/leaderboard/<string:query_type>/',
        '/v4/leaderboard/<string:query_type>',
        '/v4/leaderboard/',
        '/v4/leaderboard'
    ]

    current_app.api.add_resource(Player, *v4_player_routes, endpoint='player')
    current_app.api.add_resource(Roundup, *v4_roundup_routes, endpoint='roundup')
    current_app.api.add_resource(Leaderboard, *v4_leaderboard_routes, endpoint='leaderboard')

    # Utility Endpoints
    current_app.api.add_resource(Status, '/')
    current_app.api.add_resource(ClearCache, '/Clear_Cache')
