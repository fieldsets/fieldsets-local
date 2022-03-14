import os

class base_config():
    FLASK_ENV = os.environ.get('FLASK_ENV', 'production')
    FLASK_DEBUG = os.environ.get('FLASK_DEBUG', False)
    PL_DB_HOST = os.environ.get('PL_DB_HOST')
    PL_DB_DATABASE = os.environ.get('PL_DB_DATABASE', 'pitcher-list')
    PL_DB_USER = os.environ.get('PL_DB_USER')
    PL_DB_PW = os.environ.get('PL_DB_PW')
    BYPASS_CACHE = os.environ.get('BYPASS_CACHE', False)
    CACHE_INVALIDATE_HOUR = os.environ.get('CACHE_INVALIDATE_HOUR', 10)
    REDIS_URL = os.environ.get('REDIS_URL', '')
    API_PORT = os.environ.get('API_PORT', '8080')