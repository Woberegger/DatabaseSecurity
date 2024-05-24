# install package for pgaudit into the Postgres container
docker exec -i --tty=false -u root Postgres /bin/bash <<!
apt update -y
apt install -y postgresql-16-pgaudit
!

# as OS-user postgres modify some settings to enable pgaudit in config file
docker exec -i --tty=false -u postgres Postgres /bin/bash <<!
   cd /var/lib/postgresql/data
   # save the old config file, if we should need to rollback to that one
   cp -p postgresql.conf postgresql.conf.without_pgaudit
   sed -i "s/#shared_preload_libraries = ''/shared_preload_libraries = 'pgaudit'/" postgresql.conf
   # setting log destinations to stderr is the easiest way, it then appears in the docker logs
   sed -i "s/#log_destination = 'stderr'/log_destination = 'stderr'/" postgresql.conf
   sed -i "s/#logging_collector = off/logging_collector = on/" postgresql.conf
!

# and now some new variables for pgaudit, which are not existing yet in config file
docker exec -i --tty=false -u postgres Postgres /bin/bash <<!
cat >>/var/lib/postgresql/data/postgresql.conf <<EOF
pgaudit.log_catalog='on'
# Specify the verbosity of log information (INFO, NOTICE, LOG, WARNING,DEBUG)
pgaudit.log_level='log'
# Log the parameters being passed
pgaudit.log_parameter='on'
# Log each relation (TABLE, VIEW, etc.) mentioned in a SELECT or DML statement
pgaudit.log_relation='on'
EOF
!

# stop and start Postgres
docker stop Postgres
docker start Postgres

# create pgaudit extension in our test DB and configure read/ddl actions to log
docker exec -i --tty=false -u postgres Postgres psql <<!
\c dvdrental
CREATE EXTENSION pgaudit;
ALTER DATABASE dvdrental SET pgaudit.log = 'read,ddl';
!

# and now as user objectowner create a dummy table and check, if auditing logs this
docker exec -i --tty=false -u postgres Postgres psql -d dvdrental -U objectowner <<!
-- and now we create some dummy table to check the audit logs
drop table if exists dvd.dummy;
create table dvd.dummy (dummyint int, dummystring varchar(20));
insert into dvd.dummy values (1,'hello');
!
# the docker logging (as we have directed to stderr) should show the recent actions
docker logs Postgres | tail -n 100

