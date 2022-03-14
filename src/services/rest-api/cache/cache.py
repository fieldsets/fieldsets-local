from flask import current_app
from flask_caching import Cache
from urllib.parse import urlparse

def init_cache():
    current_app.cache = get_cache()
    return current_app.cache

# Cache Init
def get_cache():
    cache = Cache()
    redis_url = current_app.config.get('REDIS_URL')
    if redis_url == '':
        cache.init_app(current_app, config={'CACHE_TYPE': 'simple'})
    else:
        redis = urlparse(redis_url)
        cache.init_app(current_app,
                    config={
                        'CACHE_TYPE': 'redis',
                        'CACHE_KEY_PREFIX': 'PL_API_CACHE_',
                        'CACHE_REDIS_HOST': redis.hostname,
                        'CACHE_REDIS_PORT': redis.port,
                        'CACHE_REDIS_PASSWORD': redis.password,
                        'CACHE_REDIS_URL': redis_url,
                        'CACHE_OPTIONS': {'behaviors': {
                            # Faster IO
                            'tcp_nodelay': False,
                            # Keep connection alive
                            'tcp_keepalive': True,
                            # Timeout for set/get requests
                            'connect_timeout': 2000,  # ms
                            'send_timeout': 750 * 1000,  # us
                            'receive_timeout': 750 * 1000,  # us
                            '_poll_timeout': 2000,  # ms
                            # Better failover
                            'ketama': True,
                            'remove_failed': 1,
                            'retry_timeout': 2,
                            'dead_timeout': 30
                        }}
                    })
    return cache
    