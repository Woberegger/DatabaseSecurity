# shell script to download the audit trigger, copy it into docker container and run it
git clone https://github.com/2ndQuadrant/audit-trigger
docker cp audit-trigger/audit.sql Postgres:/tmp/
# IMPORTANT: set -d parameter to switch to the correct database, where the audit schema shall be installed
docker exec -it -u postgres Postgres psql -d dvdrental -f /tmp/audit.sql