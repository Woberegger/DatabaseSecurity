# DBSec08 - Postgres cluster

take care, that we all use the same IP range

```bash
NETWORK_NAME=pgcluster
$CONTAINERCMD network create -d bridge --gateway=10.0.2.1 --subnet=10.0.2.0/24 ${NETWORK_NAME}
```
Docker/Podman Compose setup for a PostgreSQL cluster with 1 primary and 2 replicas, using streaming replication
with following directory Structure:
>docker_cluster/<br>
>├── docker-compose.yml<br>
>├── primary/<br>
>│   └── Dockerfile<br>
>│   └── init_primary.sh<br>
>│   └── init.sql<br>
>│   └── pg_hba.conf<br>
>│   └── repmgr.conf<br>
>├── replica(1|2)/<br>
>│   └── Dockerfile<br>
>│   └── recovery.sh<br>
>│   └── recovery.conf<br>
>│   └── repmgr.conf<br>
>│   └── postgresql.conf<br>

in file postgresql.conf we have to change the following line (i.e. connection string to sending server)
>primary_conninfo = 'host=pg-primary port=5432 user=replica password=replica_pass'

```bash
cd ~student/DatabaseSecurity/scripts/08
```

Make sure, the shell script is executable:
```bash
chmod +x docker_cluster/replica1/recovery.sh docker_cluster/replica2/recovery.sh docker_cluster/primary/init_primary.sh
cd docker_cluster
ln -s docker-compose-nofailover.yaml docker-compose.yaml
```

build all 3, but first only start the primary container from docker-compose.yml
```bash
$CONTAINERCMD-compose up -d primary
```

we cannot do the following in Dockerfile, only after DB was once initialized
```bash
$CONTAINERCMD cp primary/pg_hba.conf pg-primary:/var/lib/postgresql/data/pg_hba.conf
```

restart DB in order to get this new pg_hba.conf active
```bash
$CONTAINERCMD stop pg-primary
$CONTAINERCMD start pg-primary
```

and only now try to start the replicas
```bash
$CONTAINERCMD-compose up -d replica1
$CONTAINERCMD-compose up -d replica2
```

in case your containers do not start up, you can debug them by starting only bash as entrypoint, e.g. for replica1
```bash
$CONTAINERCMD-compose run --entrypoint /bin/bash replica1
```

Wait a few seconds, then check replication
```bash
sleep 5
$CONTAINERCMD exec -it pg-primary psql -U replica -c "SELECT * FROM pg_stat_replication;"
```

expected result: *You should see 2 replicas connected*

and then check the repmgr nodes (only works: when repmgr is installed according to outcommented lines in script init_primary.sh)
```bash
$CONTAINERCMD exec -it pg-primary psql -U postgres -d replica -c "SELECT * FROM repmgr.nodes;"
```
 
and then check the content of the tables:
1. against the primary node
```bash
$CONTAINERCMD exec -it pg-primary psql -U replica -d replica -c "SELECT * FROM repSchema.repTable;"
```

2. against the replica, which should have created a backup upon creation
```bash
$CONTAINERCMD exec -it pg-replica1 psql -U replica -d replica -c "SELECT * FROM repSchema.repTable;"
```

## restarting lecture from scratch

**ONLY when you want to start from scratch, do the following 3 steps:**
```bash
$CONTAINERCMD-compose down
$CONTAINERCMD volume rm docker_cluster_primary-data docker_cluster_replica1-data docker_cluster_replica2-data
$CONTAINERCMD image rm docker_cluster-primary docker_cluster-replica1 docker_cluster-replica2
```

**ONLY in case that you have corrupted e.g. replica1, then call:**
```bash
$CONTAINERCMD-compose down -r replica1
```
