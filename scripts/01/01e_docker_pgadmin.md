# DBSec01 - install pgadmin

Installiere pgadmin (Administrationsoberfläche als Web-GUI für postgres) ebenfalls als Docker container
```bash
$CONTAINERCMD pull dpage/pgadmin4
# verwende das zuvor für Postgres konfigurierte Netzwerk
export NETWORK=my-docker-network
# hier Eure Email und ein Passwort nach Eurem Geschmack setzen, das dient für das Login in die pgAdmin Weboberfläche
# wichtig: Als gemappten Port einen > 1024 verwenden
$CONTAINERCMD run -p 5050:80 --name pgadmin4 --network ${NETWORK} \
    -e 'PGADMIN_DEFAULT_EMAIL=w.oberegger@gmx.at' \
    -e 'PGADMIN_DEFAULT_PASSWORD=SuperSecret' \
    -d dpage/pgadmin4
```

Nach dem Hochstarten mit folgendem Befehl abfragen, welche IPs vergeben wurden
```bash
$CONTAINERCMD network inspect my-docker-network
```

damit man in pgadmin the psql shell commandos verwenden kann (was in Produktivsystem ein Security-Risiko in der Webversion wäre)
ist folgendes zu machen:
```bash
$CONTAINERCMD cp pgadmin4:/pgadmin4/config.py .
sed -i 's/ENABLE_PSQL = False/ENABLE_PSQL = True/' config.py
$CONTAINERCMD cp config.py pgadmin4:/pgadmin4/
$CONTAINERCMD stop pgadmin4
$CONTAINERCMD start pgadmin4
```

in pgAdmin auf der Webseite [](http://<ip-of-OpenStackVM>:5050) für die Serververbindung diejenige IP als Verbindung zur Datenbank konfigurieren,
die bei obigem "$CONTAINERCMD network inspect" für den Container "Postgres" angezeigt wird, also z.B. 172.20.160.2

später, wenn der Container runtergefahren wurde, wie folgt vorgehen zum Wiederhochfahren und Einloggen
```bash
$CONTAINERCMD start pgadmin4
```