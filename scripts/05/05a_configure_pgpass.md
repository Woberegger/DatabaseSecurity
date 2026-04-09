# DBSec05 - configure Postgres wallet with PGPASSFILE

create a new OS user, which shall be allowed to login passwordless with .pgpass file
The OS and DB user do not need to have to be named identically, it's just to show the mapping
```bash
$CONTAINERCMD exec -i --tty=false Postgres /bin/bash <<!
   useradd -m -d /home/objectowner -s /bin/bash -g postgres objectowner
   echo "objectowner:my-secret-pw" | chpasswd
!
```

to be on the save side first copy the config file locally, so in case of a wrong record a broken container can be fixed!!!
first find proper path, where pg_hba.conf is located - and then copy the file from there to local drive
```bash
PGDATA=$($CONTAINERCMD exec -i --tty=false -u postgres Postgres bash -c "echo \$PGDATA")
$CONTAINERCMD cp Postgres:$PGDATA/pg_hba.conf /tmp/
```
first replace security settings, that only postgres user does not need to provide a password, i.e. trusted authentication removed from others
```bash
$CONTAINERCMD cp ~student/DatabaseSecurity/scripts/05/pg_hba.conf.pgpass Postgres:$PGDATA/pg_hba.conf
```

and Users other than `postgres` have to use md5-checksum passwords, so following lines (among others) are expected in the file:<br>
>*local    all             postgres                                trust*
>*local    all             all                                     md5*

and restart the database (or to be on the save side stop and start docker container), as somehow "service postgresql restart" does not seem to work
```bash
$CONTAINERCMD stop Postgres
$CONTAINERCMD start Postgres
```

in case the container should not start again properly, there was an error in the configuration file and you should restore your copy from /tmp.

enter container with psql command and the newly created user (-u ... OS-user, -U ... DB-User)
you should be asked for password `my-secret-pw` for `-U objectowner`, but directly get the psql prompt for `-U postgres`
```bash
$CONTAINERCMD exec -it -u objectowner Postgres psql -d ims -U objectowner
```

then change to the newly created user (in docker container) to use a password in .pgpass
```bash
$CONTAINERCMD exec -it -u root Postgres /bin/bash
su - objectowner
echo "export PGPASSFILE=\$HOME/.pgpass" >>.bashrc
echo "localhost:5432:ims:objectowner:my-secret-pw" >$HOME/.pgpass
echo "*:5432:ims:objectowner:my-secret-pw" >>$HOME/.pgpass
echo "127.0.0.1:5432:ims:objectowner:my-secret-pw" >>$HOME/.pgpass
chmod 600 $HOME/.pgpass
source .bashrc
exit # exit su command
exit # exit docker container
```

enter container with psql command and the newly created user (-u ... OS-user, -U ... DB-User)
you should not be asked for a password, but directly see the psql prompt
```bash
$CONTAINERCMD exec -it -u objectowner Postgres psql -d ims -U objectowner
```

optionally try in 2 steps to first log into OS and then into database
```bash
$CONTAINERCMD exec -it -u objectowner -w /home/objectowner Postgres /bin/bash
psql -U objectowner -d ims
```

and in contrary the following command will ask for password of user "readonly", which is "read-only-pw"
```bash
$CONTAINERCMD exec -it -u objectowner Postgres psql -d ims -U readonly
```

additional test: connect to Postgres container dbsecIMSxx of different student in group - this should also work without password
```bash
$CONTAINERCMD exec -it -u objectowner Postgres psql -d ims -h <IP-Address> -U objectowner
```