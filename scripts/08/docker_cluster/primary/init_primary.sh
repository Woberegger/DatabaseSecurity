#!/bin/bash
# do necessary first installation steps, i.e. create users and tables
# this script is called as "postgres" user by script init_primary.sh
psql -f /tmp/init.sql
