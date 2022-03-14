from flask import current_app

# legacy v2 enpoints
def init_v2_resource_endpoints():
    # Import after current app has been setup to use @current_app.cache.cached decorator
    from .resources import Leaderboard_2, Leaderboard_2_1
    # v2 Endpoints
    current_app.api.add_resource(Leaderboard_2, '/v2/leaderboard/leaderboard=<string:leaderboard>&handedness=<string:handedness>&opponent_handedness=<string:opponent_handedness>&league=<string:league>&division=<string:division>&team=<string:team>&home_away=<string:home_away>&year=<string:year>&month=<string:month>&half=<string:half>&arbitrary_start=<string:arbitrary_start>&arbitrary_end=<string:arbitrary_end>')
    current_app.api.add_resource(Leaderboard_2_1, '/v2_1/leaderboard/leaderboard=<string:leaderboard>&tab=<string:tab>&handedness=<string:handedness>&opponent_handedness=<string:opponent_handedness>&league=<string:league>&division=<string:division>&team=<string:team>&home_away=<string:home_away>&year=<string:year>&month=<string:month>&half=<string:half>&arbitrary_start=<string:arbitrary_start>&arbitrary_end=<string:arbitrary_end>')
