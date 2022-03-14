#!flask/bin/python
from flask import Flask
from flask_restful import Resource, Api
from cache import init_cache
from resources import init_resource_endpoints
from config import base_config

application = Flask(__name__)
application.config

# Set API in our current_app context
def init_api():
    application.api = Api(application)
    return application.api

with application.app_context():
    application.config.from_object(base_config)
    init_api()
    init_cache()
    init_resource_endpoints()

if __name__ == '__main__':
    apiport = application.config.get('API_PORT')
    # db_connection = get_connection()
    application.run(host='0.0.0.0', port=apiport)
