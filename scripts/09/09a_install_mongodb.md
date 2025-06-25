# see https://www.mongodb.com/resources/products/compatibilities/docker
# docker image is approx. 1.3 GB big
docker pull mongodb/mongodb-community-server
# expose port 27017, as we need to access it from externally
export NETWORK=my-docker-network
export MONGODB_VERSION=latest
# with the volume mount we can persist the data, even if container should be deleted
### the following would be the interactive docker run command, but we better use docker-compose ###
#docker run --name mongodb --network ${NETWORK} -d -p 27017:27017 -v /root/mongodb/data:/mongodb/data \
#   -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=my-secret-pw mongodb/mongodb-community-server:$MONGODB_VERSION
cd ~student/DatabaseSecurity/scripts/09
docker-compose -f 09b_mongodb-docker-compose.yaml up -d

# as GUI we will use IntelliJ, however if you want to install compass GUI, you can download it from following URL
# https://downloads.mongodb.com/compass/mongodb-compass-1.46.1-win32-x64.exe

# connect to MongoDB from different docker, e.g. MongoDB Atlas
# docker run -d --name MYAPP -e MONGODB_CONNSTRING=mongodb+srv://admin:my-secret-pw@clusterURL MYAPP:1.0

# evaluate in one, if docker container is working and connection is possible
docker exec -it -u root mongodb mongosh mongodb://admin:my-secret-pw@mongodb:27017 --eval "show dbs;"

# the simply mongoapp will only display the installed databases and then stop
docker start mongoapp
docker logs mongoapp