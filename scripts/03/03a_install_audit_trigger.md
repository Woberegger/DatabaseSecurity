# shell script to download the audit trigger, copy it into docker container and run it
git clone https://github.com/2ndQuadrant/audit-trigger
docker cp audit-trigger/audit.sql Postgres:/tmp/
docker exec -it -u postgres Postgres psql -f /tmp/audit.sql