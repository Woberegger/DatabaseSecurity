#see https://github.com/dbeaver/cloudbeaver/wiki/Run-Docker-Container how to configure and start container
docker pull dbeaver/cloudbeaver
export NETWORK=my-docker-network
# run container and provide port 8080 to access via http://localhost:8080
docker run --name cloudbeaver --network ${NETWORK} -ti -p 8080:8978 -d -v /opt/cloudbeaver/workspace dbeaver/cloudbeaver:latest

# optionally installing from Debian package is also possible
#wget https://dbeaver.com/files/dbeaver-le_latest_amd64.deb

docker exec -it -u root cloudbeaver /bin/bash
cd /root
echo "*:5432:dvdrental:objectowner:my-secret-pw" >.pgpass
chmod 600 .pgpass