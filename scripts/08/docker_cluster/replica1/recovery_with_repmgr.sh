#!/bin/bash
# This initializes the replica using pg_basebackup.
# and additionally configures automatic failover

# Install repmgr
#apt-get update && apt-get install -y wget
#echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list
#wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
#
## Install repmgr
#apt-get update && apt-get install -y postgresql-17-repmgr
 
if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "Cloning from primary..."
  pg_basebackup -h pg-primary -D "$PGDATA" -U replica -Fp -Xs -P -R
  #repmgr -h pg-primary -U repmgr -d repmgr -D "$PGDATA" standby clone
  chown -R postgres:postgres "$PGDATA"
  #repmgr -f /etc/repmgr.conf standby register
fi
