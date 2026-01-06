# DBSec01 - install dbeaver

Installiere dbeaver (einfache Abfrageoberfläche als Web-GUI für diverse Datenbanken) ebenfalls als Docker container
siehe [DBeaver-Docker-Howto](https://github.com/dbeaver/cloudbeaver/wiki/Run-Docker-Container) how to configure and start container
```bash
docker pull dbeaver/cloudbeaver
export NETWORK=my-docker-network
# run container and provide port 8978 to access via http://<VM-Host>:8978, e.g. http://dbsec0:8978
docker run --name cloudbeaver --network ${NETWORK} -ti -p 8978:8978 -d -v /opt/cloudbeaver/workspace --log-opt max-size=100m dbeaver/cloudbeaver:latest 
```

optionally installing Dbeaver natively from Debian package is also possible (but was not tested yet)
```bash
wget https://dbeaver.com/files/dbeaver-le_latest_amd64.deb
```

we will use this later in session5 to test Postgres login with pgpass
```bash
docker exec -i --tty=false -u root cloudbeaver /bin/bash <<!
cd /root
echo "*:5432:dvdrental:objectowner:my-secret-pw" >.pgpass
chmod 600 .pgpass
!
```

when connecting to dbeaver under [](http://<VM-Host>:8978) you should use following credentials:
* User: cbadmin
* Password: My-secret-pw123