# DBSec01 - install pgadmin

Install pgadmin (administration tool for Postgres as Web-GUI), also as docker container
```bash
$CONTAINERCMD pull dpage/pgadmin4
# use the same network, as we configured for our Postgres database, so that the containers may communicate to each other
export NETWORK=my-docker-network
# pls set email and self-chosen password, which you use to login to pgadmin web GUI 
# IMPORTANT: you have to use a mapped port > 1024
$CONTAINERCMD run -p 5050:80 --name pgadmin4 --network ${NETWORK} \
    -e 'PGADMIN_DEFAULT_EMAIL=w.oberegger@gmx.at' \
    -e 'PGADMIN_DEFAULT_PASSWORD=SuperSecret' \
    -d dpage/pgadmin4
```

After having started the container, check the used IP addresses with following tool<br>
(as you will need them in pgadmin to connect to the Postgres container)
```bash
$CONTAINERCMD network inspect my-docker-network
```

in order to use `psql` shell commands (what in a productive system would be a security risk, but is comfortable in our lab sessions)<br>
you have to do the following (by transfering the config file from container to host, modify it, then transfer it back and restart the container):
```bash
$CONTAINERCMD cp pgadmin4:/pgadmin4/config.py .
sed -i 's/ENABLE_PSQL = False/ENABLE_PSQL = True/' config.py
$CONTAINERCMD cp config.py pgadmin4:/pgadmin4/
$CONTAINERCMD stop pgadmin4
$CONTAINERCMD start pgadmin4
```

in pgAdmin on web GUI [](http://<ip-of-OpenStackVM>:5050) you have to configure the server connection with that IP,<br>
which the previous `$CONTAINERCMD network inspect` call has returned for the container named "Postgres", so e.g. 172.20.160.2

later, when the `pgadmin` container was stopped, you can simply start it again using following call:
```bash
$CONTAINERCMD start pgadmin4
```