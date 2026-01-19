# DBSec08 - prepare cluster configuration

execute this inside of all 3 docker containers
```bash
docker exec -it node[1|2|3] /bin/bash
```

execute this inside of docker containers
```bash
POSTGRES_VERSION=17
DATA_DIRECTORY="/var/lib/postgresql/data"
LOGS_DIRECTORY="/var/lib/postgresql/data/log"
BIN_DIRECTORY="/usr/lib/postgresql/${POSTGRES_VERSION}/bin"
CONFIG_DIRECTORY="/usr/lib/postgresql/${POSTGRES_VERSION}/config"
```

*TODO: this necessary only once, so best use it in a docker compose script*
```bash
cat >>$DATA_DIRECTORY/pg_hba.conf <<!
host     replication     postgres        node1                   trust
host     replication     postgres        node2                   trust
host     replication     postgres        node3                   trust
!
```

```bash
docker exec -it node1 /bin/bash
```

*TODO: this necessary only once (and only on master node), so best use it in a docker compose script*
```bash
sed -i 's/#wal_level = replica/wal_level = hot_standby/' $DATA_DIRECTORY/postgresql.conf
sed -i 's/#max_wal_senders/max_wal_senders/' $DATA_DIRECTORY/postgresql.conf
sed -i 's/#hot_standby = on/hot_standby = on/' $DATA_DIRECTORY/postgresql.conf
```

