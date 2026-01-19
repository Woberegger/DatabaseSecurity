# DBSec08 - Postgres cluster simple

Here's a simple how-to for setting up a PostgreSQL cluster using 3 Docker containers<br>
1 primary<br>
and 2 replicas<br>
using streaming replication.

We'll use the official PostgreSQL Docker image for that

## Step-by-Step Guide

1.Create a Docker Network
```bash
docker network create pg-cluster-net
```
2. Create a Docker Volume for Data Persistence
```bash
docker volume create pg-primary-data
docker volume create pg-replica1-data
docker volume create pg-replica2-data
```

3. Start the Primary PostgreSQL Container
```bash
docker run -d \
  --name pg-primary \
  --network pg-cluster-net \
  -e POSTGRES_USER=replica \
  -e POSTGRES_PASSWORD=replica_pass \
  -e POSTGRES_DB=postgres \
  -v pg-primary-data:/var/lib/postgresql/data \
  postgres:latest
```
Wait a few seconds for it to initialize.

4. Configure Replication on the Primary
connect with bash to the primary container:
```bash
docker exec -i --tty=false pg-primary bash <<!
#Inside the container (check, if the values already exist):
echo "host replication replica 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf
echo "wal_level = replica" >> /var/lib/postgresql/data/postgresql.conf
echo "max_wal_senders = 10" >> /var/lib/postgresql/data/postgresql.conf
echo "wal_keep_size = 64" >> /var/lib/postgresql/data/postgresql.conf
echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf
!
docker restart pg-primary
```

5. Clone the Data to two Replicas
```bash
docker run --rm \
  --network pg-cluster-net \
  -v pg-replica1-data:/var/lib/postgresql/data \
  postgres:latest \
  bash -c "PGPASSWORD=replica_pass pg_basebackup -h pg-primary -D /var/lib/postgresql/data -U replica -Fp -Xs -P -R"
```

```bash
docker run --rm \
  --network pg-cluster-net \
  -v pg-replica2-data:/var/lib/postgresql/data \
  postgres:latest \
  bash -c "PGPASSWORD=replica_pass pg_basebackup -h pg-primary -D /var/lib/postgresql/data -U replica -Fp -Xs -P -R"
```

6. Start Replica Containers
```bash
docker run -d \
  --name pg-replica1 \
  --network pg-cluster-net \
  -v pg-replica1-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=replica_pass \
  postgres:latest
```

```bash
docker run -d \
  --name pg-replica2 \
  --network pg-cluster-net \
  -v pg-replica2-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=replica_pass \
  postgres:16
```

7. Check Replication Status
(on the primary node)
```bash
docker exec -it pg-primary psql -U replica -c "SELECT * FROM pg_stat_replication;"
```

Expected result: *You should see the two replicas connected.*