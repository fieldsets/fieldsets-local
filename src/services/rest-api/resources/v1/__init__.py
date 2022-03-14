from flask import current_app

# legacy v1 enpoints
def init_v1_resource_endpoints():
    # Import after current app has been setup to use @current_app.cache.cached decorator
    from .resources import AdvancedPitcher, AdvancedHitter, AdvancedPitchType, ApproachPitcher, ApproachHitter, ApproachPitchType, DisciplinePitcher, DisciplineHitter, DisciplinePitchType, BattedPitcher, BattedHitter, BattedPitchType, StandardPitcher, StandardHitter, StandardPitchType, OverviewPitcher, OverviewHitter, OverviewPitchType, Pitcher, Hitter, PitchType, Schedule
    
    # v1 Leaderboard Endpoints
    current_app.api.add_resource(AdvancedPitcher, '/v1/Advanced/Pitcher/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(AdvancedHitter, '/v1/Advanced/Hitter/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(AdvancedPitchType, '/v1/Advanced/Pitch/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(ApproachPitcher, '/v1/Approach/Pitcher/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(ApproachHitter, '/v1/Approach/Hitter/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(ApproachPitchType, '/v1/Approach/Pitch/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(DisciplinePitcher, '/v1/Discipline/Pitcher/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(DisciplineHitter, '/v1/Discipline/Hitter/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(DisciplinePitchType, '/v1/Discipline/Pitch/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(BattedPitcher, '/v1/Batted/Pitcher/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(BattedHitter, '/v1/Batted/Hitter/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(BattedPitchType, '/v1/Batted/Pitch/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(StandardPitcher, '/v1/Standard/Pitcher/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(StandardHitter, '/v1/Standard/Hitter/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(StandardPitchType, '/v1/Standard/Pitch/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(OverviewPitcher, '/v1/Overview/Pitcher/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(OverviewHitter, '/v1/Overview/Hitter/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')
    current_app.api.add_resource(OverviewPitchType, '/v1/Overview/Pitch/start_date=<string:start_date>&end_date=<string:end_date>&year=<string:year>&month=<string:month>&half=<string:half>')


    # v1 Player Endpoints
    current_app.api.add_resource(Pitcher, '/v1/Pitcher/player_id=<string:player_id>&leaderboard=<string:leaderboard>')
    current_app.api.add_resource(Hitter, '/v1/Hitter/player_id=<string:player_id>&leaderboard=<string:leaderboard>')
    current_app.api.add_resource(PitchType, '/v1/Pitch/player_id=<string:player_id>&leaderboard=<string:leaderboard>')

    # Schedule Endpoint
    current_app.api.add_resource(Schedule, '/v1/Schedule/<string:game_date>')