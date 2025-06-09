#!/bin/bash
# should replace /usr/local/bin/docker-entrypoint.sh on the docker containers...
POSTGRES_VERSION=17
DATA_DIRECTORY="/var/lib/postgresql/data"
LOGS_DIRECTORY="/var/lib/postgresql/data/log"
BIN_DIRECTORY="/usr/lib/postgresql/${POSTGRES_VERSION}/bin"
CONFIG_DIRECTORY="/usr/lib/postgresql/${POSTGRES_VERSION}/config"


# TODO: this is the default script, but as we already have an installed database on the postgres container,
#       we first have to delete the DATA_DIRECTORY contents on the slave nodes and copy an adapted recovery.conf file there

echo ">>> TEST IF DATA DIRECTORY IS EMPTY"
if [ -z "$(ls -A $DATA_DIRECTORY)" ]; then
    echo ">>> PREPARE NODE $NODE_NAME FOR FIRST STARTUP"
    if [ "$NODE_NAME" = "$MASTER_NAME" ]
    then
        echo ">>> CREATE DATA DIRECTORY ON THE MASTER NODE"
        $BIN_DIRECTORY/initdb -D $DATA_DIRECTORY
        echo ">>> COPY CONFIGURATION FILES"
        cp $CONFIG_DIRECTORY/postgresql.conf $DATA_DIRECTORY
        cp $CONFIG_DIRECTORY/pg_hba.conf $DATA_DIRECTORY
    else
        echo ">>> $NODE_NAME IS WAITING MASTER IS UP AND RUNNING"
        while ! nc -z $MASTER_NAME 5432; do sleep 1; done;
        sleep 10
        echo ">>> REPLICATE DATA DIRECTORY ON THE SLAVE $NODE_NAME"
        $BIN_DIRECTORY/pg_basebackup -h 10.0.2.31 -p 5432 -U postgres -D $DATA_DIRECTORY -X stream -P
        echo ">>> COPY recovery.conf ON SLAVE $NODE_NAME"
        cp CONFIG_DIRECTORY/recovery.conf $DATA_DIRECTORY
        sed -i "s/NODE_NAME/$NODE_NAME/g" $DATA_DIRECTORY/recovery.conf
        sed -i "s/MASTER_NAME/$MASTER_NAME/g" $DATA_DIRECTORY/recovery.conf
    fi
fi
echo ">>> START POSTGRESQL ON NODE $NODE_NAME"
$BIN_DIRECTORY/postgres -D $DATA_DIRECTORY > $LOGS_DIRECTORY/postgres.log 2>&1
    