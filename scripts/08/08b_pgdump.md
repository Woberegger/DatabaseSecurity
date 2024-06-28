# execute the following commands inside of your Postgres docker container
docker exec -it -u postgres Postgres /bin/bash
# set variables
old_db=dvdrental
new_db=dvdcopy
mkdir /tmp/backups
db_dump_file="/tmp/backups/dvdrental.pg.dump"

# export DB
pg_dump -U postgres -F custom "$old_db" > "$db_dump_file"

# create new DB (first try to delete it, if it should already exist)
dropdb   -U postgres --if-exists  "$new_db"
createdb -U postgres -T template0 "$new_db"
# finally import data into new DB
pg_restore -U postgres -d "$new_db" "$db_dump_file"
# verify contents of DB using psql or pgadmin or similar client tool
psql <<!
\c dvdcopy
select count(*) from dvd.actor;
!