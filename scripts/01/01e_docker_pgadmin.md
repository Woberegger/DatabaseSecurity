# Installiere pgadmin ebenfalls als Docker container
docker pull dpage/pgadmin4
# verwende das zuvor für Postgres konfigurierte Netzwerk
export NETWORK=my-docker-network
# hier Eure Email und ein Passwort nach Eurem Geschmack setzen, das dient für das Login in die pgAdmin Weboberfläche
# wichtig: Als gemappten Port einen > 1024 verwenden
docker run -p 5050:80 --name pgadmin4 --network ${NETWORK} \
    -e 'PGADMIN_DEFAULT_EMAIL=w.oberegger@gmx.at' \
    -e 'PGADMIN_DEFAULT_PASSWORD=SuperSecret' \
    -d dpage/pgadmin4

# Nach dem Hochstarten mit folgendem Befehl abfragen, welche IPs vergeben wurden
docker network inspect my-docker-network

# in pgAdmin auf der Webseite http://localhost:5050 für die Serververbindung diejenige IP angeben, die hier für den Container "Postgres" angezeigt wird,
# also z.B. 172.20.160.2

###### später, wenn der Container runtergefahren wurde, wie folgt vorgehen zum Wiederhochfahren und Einloggen #########
docker start pgadmin4
