######################################################
# Let's clone from redis official image repository
# https://hub.docker.com/_/redis
######################################################

FROM redis

######################################################
# Let's copy our own (custom) redis configuration file
# instead of the default one.
# NOTE: The only change in this conf file is the port. 
# I changed it to 6300 instead of redis's default 6379
# just for illustration purposes. You can customize it
# with any other property you wish to modify!
######################################################

COPY config/redis.conf /usr/local/etc/redis/redis.conf

#####################################################
# run the redis start command!
#####################################################

CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]