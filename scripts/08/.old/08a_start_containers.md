### docker containers to simulate a Postgres cluster ###
# PostgreSQL node names
NODE1_NAME=node1
NODE2_NAME=node2
NODE3_NAME=node3

MASTER_NAME=${NODE1_NAME}

# use new exposed ports, which do not interfere with our existing postgres container
NODE1_PORT=5433
NODE2_PORT=5434
NODE3_PORT=5435

# Nodes private ips
NODE1_IP=10.0.2.31
NODE2_IP=10.0.2.32
NODE3_IP=10.0.2.33

# Nodes private network name
export NETWORK_NAME=pgcluster

# Create a private network
docker network create -d bridge --gateway=10.0.2.1 --subnet=10.0.2.0/24 ${NETWORK_NAME}

# Create the PostgreSQL containers and start them
# only for the master node we execute the "run" command, which will init the database, the others we only create
docker run --name $NODE1_NAME --network ${NETWORK_NAME} --ip ${NODE1_IP} --env NODE_NAME=${NODE1_NAME} --env MASTER_NAME=${MASTER_NAME} -p ${NODE1_PORT}:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=my-secret-pw -d postgres:latest
#
docker create -it --net ${NETWORK_NAME} --ip ${NODE2_IP} --hostname ${NODE2_NAME} --name ${NODE2_NAME} --env NODE_NAME=${NODE2_NAME} --env MASTER_NAME=${MASTER_NAME} -p ${NODE2_PORT}:5432 postgres:latest /bin/bash
docker create -it --net ${NETWORK_NAME} --ip ${NODE3_IP} --hostname ${NODE3_NAME} --name ${NODE3_NAME} --env NODE_NAME=${NODE3_NAME} --env MASTER_NAME=${MASTER_NAME} -p ${NODE3_PORT}:5432 postgres:latest /bin/bash

#docker exec ${NODE2_NAME} rm -Rf /var/lib/postgresql/data/*
# go to directory, where the scripts for this lecture are stored, e.g.
cd ~student/DatabaseSecurity/scripts/08
docker cp recovery.conf.node2 ${NODE2_NAME}:/var/lib/postgresql/data/recovery.conf
docker cp recovery.conf.node3 ${NODE3_NAME}:/var/lib/postgresql/data/recovery.conf

docker start ${NODE1_NAME}
docker start ${NODE2_NAME}
docker start ${NODE3_NAME}