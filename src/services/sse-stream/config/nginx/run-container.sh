########################################################
# Let's run a Docker container based on our image
# NOTE: Since our nginx config was customized to run on
# port 80 we need to map ports with the -p flag. In this
# case I chose port 4400 but you can choose any you wish!
# It goes like this: -p HOST_PORT : CONTAINER_PORT
########################################################
 
docker run -p 4400:80 sse-tutorial-proxy 