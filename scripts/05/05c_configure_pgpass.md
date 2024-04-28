# configure Postgres wallet with PGPASSFILE
docker exec -it Postgres /bin/bash
su - postgres
echo "export PGPASSFILE='~/.pgpass'" >>.bashrc
source .bashrc
echo "*:5432:dvdrental:postgres:my-secret-pw" >$HOME/.pgpass
chmod 600 $HOME/.pgpass