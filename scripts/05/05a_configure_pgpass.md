# configure Postgres wallet with PGPASSFILE
docker exec -it Postgres /bin/bash
# create a new OS user, which shall be allowed to login passwordless with .pgpass file
# The OS and DB user do not need to have to be named identically, it's just to show the mapping
useradd -m -d /home/objectowner -s /bin/bash -g postgres objectowner
passwd objectowner
exit
# to be on the save side first copy the config file locally, so in case of a wrong record a broken container can be fixed!!!
docker cp Postgres:/var/lib/postgresql/data/pg_hba.conf /tmp/
# first replace security settings, that only postgres user does not need to provide a password, i.e. trusted authentication removed from others
docker cp scripts/05/pg_hba.conf.pgpass Postgres:/var/lib/postgresql/data/pg_hba.conf
# and User "objectowner" has to use md5-checksum passwords, so following line is expected in the file
#local dvdrental objectowner md5

# and restart the database (or to be on the save side stop and start docker container)
service postgresql restart
# then change to the newly created user
su - objectowner
echo "export PGPASSFILE=\$HOME/.pgpass" >>.bashrc
echo "localhost:5432:dvdrental:objectowner:my-secret-pw" >$HOME/.pgpass
echo "*:5432:dvdrental:objectowner:my-secret-pw" >>$HOME/.pgpass
echo "127.0.0.1:5432:dvdrental:objectowner:my-secret-pw" >>$HOME/.pgpass
chmod 600 $HOME/.pgpass
source .bashrc
exit # exit su command
exit # exit docker container
# enter docker container with psql command and the newly created user (-u ... OS-user, -U ... DB-User)
docker exec -it -u objectowner Postgres psql -d dvdrental -U objectowner
# optionally try in 2 steps to first log into OS and then into database
docker exec -it -u objectowner Postgres /bin/bash
psql -U objectowner -d dvdrental