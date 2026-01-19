# DBSec09 - install Mongo DB

for compatibility see [](https://www.mongodb.com/resources/products/compatibilities/docker)

Take care for enough disk space - docker image is approx. 1.3 GB big
```bash
docker pull mongodb/mongodb-community-server
```

we use existing network, where we will expose port 27017, which we need to access the container from externally
```bash
export NETWORK=my-docker-network
export MONGODB_VERSION=latest
```

with the volume mount we can persist the data, even if container should be deleted
(the following would be the interactive docker run command, but we better use docker-compose)
>docker run --name mongodb --network export NETWORK=my-docker-network -d <br>
>  -p 27017:27017 -v /root/mongodb/data:/mongodb/data<br>
>  -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=my-secret-pw <br>
>  mongodb/mongodb-community-server:$MONGODB_VERSION

```bash
cd ~student/DatabaseSecurity/scripts/09
docker-compose -f 09b_mongodb-docker-compose.yaml up -d
```

as GUI we will use IntelliJ, however if you want to install compass GUI, you can download it from following URL:<br>
[Compass-GUI download link](https://downloads.mongodb.com/compass/mongodb-compass-1.46.1-win32-x64.exe)

to connect to MongoDB from different docker, e.g. MongoDB Atlas execute
```bash
docker run -d --name MYAPP -e MONGODB_CONNSTRING=mongodb+srv://admin:my-secret-pw@clusterURL MYAPP:1.0
```

evaluate locally in mongoDB container, if docker container is working and connection is possible
```bash
docker exec -it -u root mongodb mongosh mongodb://admin:my-secret-pw@mongodb:27017 --eval "show dbs;"
```

the simply mongoapp will only display the installed databases and then stop
```bash
docker start mongoapp
docker logs mongoapp
```