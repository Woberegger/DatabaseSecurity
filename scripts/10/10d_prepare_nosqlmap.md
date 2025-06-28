# all actions on OpenStack platform as superuser
cd /usr/local/src
git clone https://github.com/codingo/NoSQLMap.git
cd NoSQLMap/docker
# as the tool requires old python 2.7. we better use the docker version of it
export NETWORK=my-docker-network
docker build -t nosqlmap .

docker run -it --name nosqlmap --network ${NETWORK} nosqlmap
# after stopping it you might either start it with "docker start nosqlmap" or remove the previous one with following command
docker rm $(docker ps -a -q --filter ancestor=nosqlmap)
 