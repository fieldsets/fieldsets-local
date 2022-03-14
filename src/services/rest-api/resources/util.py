from flask import current_app
from flask_restful import Resource

# Top level / Endpoint
class Status(Resource):
    def get(self):
        return {'status': 'available'}
        
# /Clear_Cache Endpoint
class ClearCache(Resource):
    def get(self):
        current_app.cache.clear()
        return {'status': "cache cleared"}