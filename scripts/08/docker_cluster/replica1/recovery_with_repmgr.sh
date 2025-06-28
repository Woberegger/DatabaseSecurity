#!/bin/bash
# This configures automatic failover
# TODO: currently this does not work, when copied in Dockerfile instead of recovery.sh, so execute commands
#       interactively in bash on both replica nodes

# Install repmgr and wget as preparation (needs to be done on pg-primary, too)
apt-get update && apt-get install -y wget
echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
#
apt-get update && apt-get install -y postgresql-17-repmgr

service postgresql stop
su - postgres
# rm the database, which is installed per default in the image
rm -Rf /var/lib/postgresql/data/PG_VERSION /var/lib/postgresql/data/base /var/lib/postgresql/data/global /var/lib/postgresql/data/pg_*
# check if variable is correctly set to /var/lib/postgresql/data
export PGDATA=/var/lib/postgresql/data
if [ ! -s "$PGDATA" ]; then
  echo "Cloning from primary..."
  export PGPASSWORD=my-secret-pw #replica_pass
  repmgr -h pg-primary -U postgres -d replica -D "$PGDATA" standby clone
  repmgr -f /etc/repmgr.conf standby register
fi
