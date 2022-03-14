########################################################
# Let's run a Docker container based on our image
# NOTE: Since our redis config was customized to run on
# port 6300 we need to map ports with the -p flag. 
# It goes like this: -p HOST_PORT : CONTAINER_PORT
########################################################
 
docker run -p 6379:6300 sse-tutorial-db