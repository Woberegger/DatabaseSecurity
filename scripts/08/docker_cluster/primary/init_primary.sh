#!/bin/bash
# do necessary first installation steps, i.e. create users and tables
# this script is anyway called as "postgres" user
psql -f /docker-entrypoint-initdb.d/init.sql

# and also the following we need to do manually as root user instead
#apt-get update && apt-get install -y wget
#echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list
#wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
#
## Install repmgr
#apt-get update && apt-get install -y postgresql-17-repmgr
# 
## Register primary node
#su - postgres -c "repmgr -f /etc/repmgr.conf primary register"
