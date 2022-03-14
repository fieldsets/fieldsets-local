from flask import current_app
from cache import cache_timeout, cache_invalidate_hour
from helpers import fetch_dataframe
import json as json
import pandas as pd

##
# Return team info
##
def get_team_info(team=None):

    query = f'SELECT abbreviation, team_name, mlb_id, league, division FROM teams'
    cache_key = f'team-info-all'

    if (team):
        query = f'{query} WHERE abbreviation=%s'
        cache_key = f'team-info-{team}'

    json_result = current_app.cache.get(cache_key)

    if (current_app.config.get('BYPASS_CACHE') or json_result is None):
        result = fetch_dataframe(query, team)

        indexed_result = result.set_index(['abbreviation'])
        indexed_result.fillna(value=json.dumps(None), inplace=True)

        json_result = indexed_result.to_json(orient='index', date_format='iso')
        # All cached items are stored as json.
        if (not current_app.config.get('BYPASS_CACHE')):
            current_app.cache.set(cache_key, json_result, cache_timeout(cache_invalidate_hour()))

    # Return a python dict
    return json.loads(json_result)
