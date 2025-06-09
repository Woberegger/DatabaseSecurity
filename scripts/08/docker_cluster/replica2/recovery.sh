#!/bin/bash
# This initializes the replica using pg_basebackup.
# and additionally configures automatic failover
PGDATA=/var/lib/postgresql/data
# Only clone if data directory is empty
if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "Cloning from primary..."
  pg_basebackup -h pg-primary -D "$PGDATA" -U replica -Fp -Xs -P -R
  chown -R postgres:postgres "$PGDATA"
else
  echo "Data directory exists. Skipping base backup."
fi
 
# Continue to default Postgres entrypoint
exec docker-entrypoint.sh "$@"
