# DBSec08 - Postgres cluster with cluster control

clone Postgres image auf 2 neue Container, die dann verclustert werden<br>
damit wir die existierende Umgebung nicht beeinflussen, definieren wir ein neues Docker-Netzwerk "pgnet"
```bash
export NETWORK=pgcluster
docker network create --driver=bridge $NETWORK
export DOCKER_CONTAINERBASE=PgCluster
```

zusätzlich setze "-e POSTGRES_USER=postgres", dass als dieser DB-User eingeloggt wird<br>
starte master und slave container, verwende Ports 5433 und 5434
```bash
docker run --name ${DOCKER_CONTAINERBASE}Master --network ${NETWORK} -p 5433:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=my-secret-pw -d postgres:latest
docker run --name ${DOCKER_CONTAINERBASE}Slave --network ${NETWORK} -p 5434:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=my-secret-pw -d postgres:latest
```

```bash
docker exec -i --tty=false -u root ${DOCKER_CONTAINERBASE}Master /bin/bash <<!
   apt-get update
   # Install the openssh client
   apt-get install -y openssh-server openssh-client
   # Changing the permission for ssh
   sed -i 's|^PermitRootLogin.*|PermitRootLogin yes|g' /etc/ssh/sshd_config
   sed -i 's|^#PermitRootLogin.*|PermitRootLogin yes|g' /etc/ssh/sshd_config
   #start the service
   service ssh start
!
```
```bash
docker exec -i --tty=false -u root ${DOCKER_CONTAINERBASE}Slave /bin/bash <<!
   apt-get update
   # Install the openssh client
   apt-get install -y openssh-server openssh-client
   # Changing the permission for ssh
   sed -i 's|^PermitRootLogin.*|PermitRootLogin yes|g' /etc/ssh/sshd_config
   sed -i 's|^#PermitRootLogin.*|PermitRootLogin yes|g' /etc/ssh/sshd_config
   #start the service
   service ssh start
!
```
hole das clustercontrol docker image ab
```bash
docker pull severalnines/clustercontrol
```
```bash
docker run -d --name clustercontrol --network ${NETWORK} -p 5000:80 -p 5001:443 -p 9443:9443 \
-v /storage/clustercontrol/cmon.d:/etc/cmon.d \
-v /storage/clustercontrol/datadir:/var/lib/mysql \
-v /storage/clustercontrol/sshkey:/root/ssh \
-v /storage/clustercontrol/cmonlib:/var/lib/cmon \
-v /storage/clustercontrol/backups:/root/backups \
severalnines/clustercontrol
```

set root password to a known one in the 2 postgres containers
```bash
docker exec -it -u root ${DOCKER_CONTAINERBASE}Master /bin/bash
passwd
exit
```

```bash
docker exec -it -u root ${DOCKER_CONTAINERBASE}Slave /bin/bash
passwd
exit
```

now copy the ssh keys from the cluster to all nodes, which you have started
the following has to be done interactively "-it", as you are prompted for fingerprint acceptance
```bash
docker exec -it -u root clustercontrol /bin/bash
   ssh-copy-id PgClusterMaster # you cannot use ${DOCKER_CONTAINERBASE}Master
   ssh-copy-id PgClusterSlave # you cannot use ${DOCKER_CONTAINERBASE}Slave
   # set password for GUI user "admin"
   s9s user --change-password --new-password=my-secret-pw admin
   # after that try, if login without password is possible and directory content is shown
   ssh PgClusterMaster <<!
      ls /var/lib/postgresql/data/
!
cd /var/www/html/clustercontrol/app/tools/
php -e password-reset.php7 w.oberegger@gmx.at
```

open web page for clustercontrol [](http://localhost:5000/clustercontrol)

interaktiver login über psql SQL-Commandline in den laufenden Container<br>
über --tty=false kann man eine Kommandosequenz als Here-Document übergeben
```bash
docker exec -i --tty=false -u postgres ${DOCKER_CONTAINERBASE}Master psql <<!
   CREATE ROLE scott LOGIN PASSWORD 'FhIms2024';
   CREATE DATABASE clusterdb
   WITH 
      ENCODING = 'UTF8'
      OWNER = scott
      CONNECTION LIMIT = 100;
   \c clusterdb
!
```

wenn man Tools wie pgadmin4 in diesem Netzwerk verwenden will, ohne dafür eine neue Instanz zu erstellen:
```bash
docker network connect $NETWORK pgadmin4
docker start pgadmin4
```