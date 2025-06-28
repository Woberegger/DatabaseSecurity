# take care, that we all use the same IP range
NETWORK_NAME=pgcluster
docker network create -d bridge --gateway=10.0.2.1 --subnet=10.0.2.0/24 ${NETWORK_NAME}
# Docker Compose setup for a PostgreSQL cluster with 1 primary and 2 replicas, using streaming replication.
# Directory Structure
docker_cluster/
├── docker-compose.yml
├── primary/
│   └── Dockerfile
│   └── init_primary.sh
│   └── init.sql
│   └── pg_hba.conf
│   └── repmgr.conf
├── replica(1|2)/
│   └── Dockerfile
│   └── recovery.sh
│   └── recovery.conf
│   └── repmgr.conf
│   └── postgresql.conf

# in file postgresql.conf we have to change the following line:
#primary_conninfo = 'host=pg-primary port=5432 user=replica password=replica_pass' # connection string to sending server

# Make sure, the shell script is executable:
chmod +x docker_cluster/replica/recovery.sh docker_cluster/primary/init_primary.sh
cd docker_cluster
ln -s docker-compose-nofailover.yaml docker-compose.yaml
# build all 3, but first only start the primary container from docker-compose.yml
docker-compose up -d primary
#
# we cannot do this in Dockerfile, only after DB was once initialized
docker cp primary/pg_hba.conf pg-primary:/var/lib/postgresql/data/pg_hba.conf
# restart DB in order to get this new pg_hba.conf active
docker stop pg-primary
docker start pg-primary
# and now try to start the replicas
docker-compose up -d replica1
docker-compose up -d replica2
# in case your containers do not start up, you can debug them by starting only bash as entrypoint, e.g. for replica1
#docker-compose run --entrypoint /bin/bash replica1

#Wait a few seconds, then check replication
sleep 5
docker exec -it pg-primary psql -U replica -c "SELECT * FROM pg_stat_replication;"
# expected result: You should see 2 replicas connected

# and then check the repmgr nodes (only works: when repmgr is installed according to outcommented lines in script init_primary.sh)
docker exec -it pg-primary psql -U postgres -d replica -c "SELECT * FROM repmgr.nodes;"
 
# and then check the content of the tables
# a) against the primary node
docker exec -it pg-primary psql -U replica -d replica -c "SELECT * FROM repSchema.repTable;"
# b) against the replica, which should have created a backup upon creation
docker exec -it pg-replica1 psql -U replica -d replica -c "SELECT * FROM repSchema.repTable;"

### when you want to start from scratch, do the following 3 steps:
#docker-compose down
#docker volume rm docker_cluster_primary-data docker_cluster_replica1-data docker_cluster_replica2-data
#docker image rm docker_cluster-primary docker_cluster-replica1 docker_cluster-replica2
 
