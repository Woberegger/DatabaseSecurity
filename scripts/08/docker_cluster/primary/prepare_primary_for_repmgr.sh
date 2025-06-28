#!/bin/bash
# this prepares automatic failover on primary node
# TODO: currently this does not work, when copied in Dockerfile, so execute commands
#       interactively in bash on primary node

# Install repmgr and wget as preparation (needs to be done on replicas, too)
apt-get update && apt-get install -y wget
echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
#
apt-get update && apt-get install -y postgresql-17-repmgr

su - postgres <<!
repmgr -f /etc/repmgr.conf primary register
!
service postgresql stop
service postgresql start
