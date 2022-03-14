######################################################
# Let's clone from nginx official image repository
# https://hub.docker.com/_/nginx
######################################################

FROM nginx

######################################################
# Let's copy our own (custom) nginx configuration file
# instead of the default one.
# NOTE: The only change in this conf file is the port. 
# I changed it to 6300 instead of redis's default 6379
# just for illustration purposes. You can customize it
# with any other property you wish to modify!
######################################################

RUN rm /etc/nginx/conf.d/*
COPY config/nginx.conf /etc/nginx/conf.d/nginx.conf

######################################################
# Let's copy our own (custom) nginx index file
######################################################

RUN mkdir /etc/nginx/html
COPY config/index.html /etc/nginx/html/index.html