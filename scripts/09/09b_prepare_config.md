#execute this inside of docker containers
DATA_DIRECTORY="/var/lib/postgresql/data"
LOGS_DIRECTORY="/var/lib/postgresql/data/log"
BIN_DIRECTORY="/usr/lib/postgresql/16/bin"
CONFIG_DIRECTORY="/usr/lib/postgresql/16/config"

# TODO: is necessary only once, so best use it in a docker compose script
sed -i 's/#wal_level = replica/wal_level = hot_standby/' $DATA_DIRECTORY/postgresql.conf
sed -i 's/#max_wal_senders/max_wal_senders/' $DATA_DIRECTORY/postgresql.conf
sed -i 's/#hot_standby = on/hot_standby = on/' $DATA_DIRECTORY/postgresql.conf

# TODO: is necessary only once, so best use it in a docker compose script
cat >>$DATA_DIRECTORY/pg_hba.conf <<!
host     replication     postgres        node1                   trust
host     replication     postgres        node2                   trust
host     replication     postgres        node3                   trust
!
