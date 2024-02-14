# Postgres container download und erster Test, indem wir eine Datenbank anlegen
sudo -s
docker pull postgres
export DOCKER_CONTAINERNAME=Postgres
# damit die einzelnen Container miteinander kommunizieren können, müssen wir sie ins selbe virtuelle Netzwerk reinhängen
# ich habe als IP-Range und Gateway die genommen, die bei "ipconfig" auf dem Host für Adapter "WSL" aufscheint
export NETWORK=my-docker-network
docker network create --driver=bridge --subnet=172.20.160.0/24 --ip-range=172.20.160.0/24 --gateway=172.20.160.1 $NETWORK
# zusätzlich setze "-e POSTGRES_USER=postgres", dass als dieser DB-User eingeloggt wird
docker run --name $DOCKER_CONTAINERNAME --network ${NETWORK} -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=my-secret-pw -d postgres:latest
# interaktiver login über psql SQL-Commandline in den laufenden Container
# über --tty=false kann man eine Kommandosequenz als Here-Document übergeben
docker exec -i --tty=false -u postgres ${DOCKER_CONTAINERNAME} psql <<!
   CREATE ROLE scott LOGIN PASSWORD 'FhIms2024';
   CREATE DATABASE ims 
   WITH 
      ENCODING = 'UTF8'
      OWNER = scott
      CONNECTION LIMIT = 100;
   \c ims
!

###### später, wenn der Container runtergefahren wurde, wie folgt vorgehen zum Wiederhochfahren und Einloggen #########
docker start Postgres
sleep 3 # give the container some time to start up
docker exec -it -u postgres Postgres psql