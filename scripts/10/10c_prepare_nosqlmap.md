# all actions on OpenStack platform as superuser
cd /usr/local/src
git clone https://github.com/codingo/NoSQLMap.git
cd NoSQLMap/docker
export NETWORK=my-docker-network
cp ~student/DatabaseSecurity/scripts/10/10c_docker-compose-nosqlmap.yml ./docker-compose.yml
docker-compose build
docker-compose run nosqlmap
# call menu points 1 and 2 according to screenshots in lecture