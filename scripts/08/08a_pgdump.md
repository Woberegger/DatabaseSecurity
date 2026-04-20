# DBSec08 - Postgres clone DB with pgdump

execute the following commands inside of your Postgres docker/podman container
```bash
$CONTAINERCMD exec -it -u postgres Postgres /bin/bash
```

set variables inside of docker container
```bash
old_db=ims
new_db=imscopy
mkdir /tmp/backups
db_dump_file="/tmp/backups/ims.pg.dump"
```

export DB
```bash
pg_dump -U postgres -F custom "$old_db" > "$db_dump_file"
```

create new DB (first try to delete it, if it should already exist)
```bash
dropdb   -U postgres --if-exists  "$new_db"
createdb -U postgres -T template0 "$new_db"
```

finally import data into new DB
```bash
pg_restore -U postgres -d "$new_db" "$db_dump_file"
```

verify contents of DB using psql or pgadmin or similar client tool
```bash
psql <<!
\c imscopy
\echo this should find all system tables and the ones we have created
select * from pg_catalog.pg_tables;
\echo this should find 200 records in table 'actor'
select count(*) from public.actor;
!
```