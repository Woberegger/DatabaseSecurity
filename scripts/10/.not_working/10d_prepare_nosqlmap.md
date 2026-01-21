# DBSec10 - prepare noSqlMap for noSQL injection

all actions on OpenStack platform as superuser
```bash
sudo -s
cd /usr/local/src
git clone https://github.com/codingo/NoSQLMap.git
cd NoSQLMap/docker
```

as the tool requires old python 2.7. we better use the docker version of it
```bash
export NETWORK=my-docker-network
docker build -t nosqlmap .
docker run -it --name nosqlmap --network ${NETWORK} nosqlmap
```

after having stopped the container you might either start it with "docker start nosqlmap" or remove the previous one with following command
and later re-create it
```bash
docker rm $(docker ps -a -q --filter ancestor=nosqlmap)
```
 