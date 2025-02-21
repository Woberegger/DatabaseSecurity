#see https://github.com/dbeaver/cloudbeaver/wiki/Run-Docker-Container how to configure and start container
docker pull dbeaver/cloudbeaver
export NETWORK=my-docker-network
# run container and provide port 8978 to access via http://<VM-Host>:8978, e.g. http://dbsec0:8978
docker run --name cloudbeaver --network ${NETWORK} -ti -p 8978:8978 -d -v /opt/cloudbeaver/workspace dbeaver/cloudbeaver:latest

# optionally installing from Debian package is also possible
#wget https://dbeaver.com/files/dbeaver-le_latest_amd64.deb

# we will use this later in session5 to test Postgres login with pgpass
docker exec -it -u root cloudbeaver /bin/bash
cd /root
echo "*:5432:dvdrental:objectowner:my-secret-pw" >.pgpass
chmod 600 .pgpass
# when connecting to dbeaver under http://<VM-Host>:8978 you should use following credentials:
# User: cbadmin
# Password: My-secret-pw123