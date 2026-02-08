# DbSec01 - install oracle

Oracle container download and initial test by listing the users:
You can use podman or docker to run the containers.
See [Oracle docker download info]( https://container-registry.oracle.com/ords/f?p=113:4:106648115637034:::4:P4_REPOSITORY,AI_REPOSITORY,AI_REPOSITORY_NAME,P4_REPOSITORY_NAME,P4_EULA_ID,P4_BUSINESS_AREA_ID:1863,1863,Oracle%20Database%20Free,Oracle%20Database%20Free,1,0&cs=3vh3v7Bx-M1AhcZcni5BZw08qK4bc49cPe_X8TG5ZkK6Z8YJb6F_7s-kOEqsi9ahcAJrOaMTAC5QDMo1FbyMgWA)

The image is about 14 GB, so please check for sufficient disk space
```bash
$CONTAINERCMD pull container-registry.oracle.com/database/free:latest
export DOCKER_CONTAINERNAME=OracleFree
export NETWORK=my-docker-network
# to make the listener port 1521 reachable from the host, expose it with "-p xxx:xxx"
$CONTAINERCMD run -d --name $DOCKER_CONTAINERNAME --network ${NETWORK} -p 1521:1521 -p 2484:2484 --log-opt max-size=100m container-registry.oracle.com/database/free:latest
sleep 5 # give DB some time to startup (when "ORA-01109: database not open" pops up, then try again
$CONTAINERCMD exec $DOCKER_CONTAINERNAME ./setPassword.sh FhIms9999
```

connect to the database with sqlplus inside the container and show which pdbs and which users exist
you can pass a command sequence as a here-document using `--tty=false`
the `-s` for sqlplus disables the SQL prompt and the startup screen, so it is recommended for non-interactive commands, otherwise not
```bash
export DOCKER_CONTAINERNAME=OracleFree
$CONTAINERCMD exec -i --tty=false $DOCKER_CONTAINERNAME sqlplus -s / as sysdba <<!
   show pdbs;
   SET lines 300 pages 0;
   SELECT UserName, user_id FROM all_users ORDER BY 2 ASC;
   -- here we do not need archive logging, which might fill up our HDD space
   -- this can only be done, when mounted only
   shutdown immediate;
   startup mount;
   alter database noarchivelog;
   archive log list;
   alter database open;
!
```

if for some reason the archive logfiles were already created and occupy a lot of space, run:
```bash
export DOCKER_CONTAINERNAME=OracleFree
$CONTAINERCMD exec -i --tty=false $DOCKER_CONTAINERNAME /bin/bash <<!
   rm /opt/oracle/oradata/dbconfig/FREE/dbs/arch*.dbf
!
```

show last outputs of the Oracle alert log
```bash
$CONTAINERCMD logs $DOCKER_CONTAINERNAME
```

since the logfiles can become very large (and even fill all storage), using logrotate is recommended (when logging into container's file system)
(this `logrotate` works with docker only, but not with podman in the usual setup, as this uses `journald` per default, as you can see from following command):

a) for podman:
```bash
podman info --format '{{.Host.LogDriver}}'
```

b) for docker only:
```bash
LogPath=$(dirname $(docker inspect --format='{{.LogPath}}' OracleFree))

cat >/etc/logrotate.d/docker-oracle-logs <<!
${LogPath}/*.log {
    daily
    rotate 3
    compress
    missingok
    notifempty
    copytruncate
}
!
# test call:
logrotate -f /etc/logrotate.d/docker-oracle-logs
```

now create a new pluggable database as a copy of the default DB `FREEPDB1`
```bash
export DOCKER_CONTAINERNAME=OracleFree
$CONTAINERCMD exec -i --tty=false $DOCKER_CONTAINERNAME sqlplus -s / as sysdba <<!
   SET lines 300 pages 0;
   -- Show the structure of the files so we can create the File_Name_Convert accordingly
   SELECT FILE_NAME FROM dba_data_files;
   CREATE Pluggable Database IMS FROM FREEPDB1 FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE/FREEPDB1/','/opt/oracle/oradata/FREE/IMS/');
   -- Switch into the existing container
   ALTER Pluggable Database IMS OPEN;
   -- ensure the container automatically starts up next time
   ALTER Pluggable Database IMS save state;
   ALTER session SET container=IMS;
   SELECT FILE_NAME FROM dba_data_files;
!
```

we must create a tns alias for the new DB so we can connect with `user/pwd@PluggableDB`
```bash
export DOCKER_CONTAINERNAME=OracleFree
$CONTAINERCMD exec -it $DOCKER_CONTAINERNAME /bin/bash
# check the path first, which changes with new versions
cat /opt/oracle/product/26ai/dbhomeFree/network/admin/tnsnames.ora

cat >>/opt/oracle/product/26ai/dbhomeFree/network/admin/tnsnames.ora <<!
IMS =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = IMS)
    )
  )
!
exit # exit from docker container
```

to keep separation later, create separate tablespaces for data and indexes
```bash
export DOCKER_CONTAINERNAME=OracleFree
$CONTAINERCMD exec -i --tty=false $DOCKER_CONTAINERNAME sqlplus -s / as sysdba <<!
   -- IMPORTANT: for most of our test applications we need to switch into the respective PDB, so don't forget the "ALTER SESSION"!!!
   ALTER session SET container=IMS;
   CREATE TABLESPACE data DATAFILE '/opt/oracle/oradata/FREE/IMS/data.dbf' SIZE 16m AUTOEXTEND ON;
   CREATE TABLESPACE indexes DATAFILE '/opt/oracle/oradata/FREE/IMS/indexes.dbf' SIZE 8m AUTOEXTEND ON;
   SELECT FILE_NAME FROM dba_data_files;
   SELECT tablespace_name, INITIAL_EXTENT, NEXT_EXTENT, ENCRYPTED, EXTENT_MANAGEMENT FROM DBA_TableSpaces;
!
```

then create an application user in our PDB under which the tables will be installed
```bash
export DOCKER_CONTAINERNAME=OracleFree
$CONTAINERCMD exec -i --tty=false $DOCKER_CONTAINERNAME sqlplus -s / as sysdba <<!
   ALTER session SET container=IMS;
   -- first create a role so we can grant it to the user; for additional users the same role can be reused
   CREATE Role Application;
   CREATE USER Ims IDENTIFIED BY FhIms9999 DEFAULT TABLESPACE DATA TEMPORARY TABLESPACE TEMP;
   GRANT CONNECT, RESOURCE, CREATE TABLE, CREATE PROCEDURE, CREATE VIEW, CREATE DATABASE LINK, CREATE SYNONYM, CREATE ANY DIRECTORY TO Application;
   GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE, Application TO Ims;
!
```

then connect for a quick test with the newly created user; it should at least find some system tables, no user tables yet
```bash
export DOCKER_CONTAINERNAME=OracleFree
$CONTAINERCMD exec -i --tty=false $DOCKER_CONTAINERNAME sqlplus -s ims/FhIms9999@IMS <<!
   SELECT Table_Name FROM All_Tables WHERE RowNum<=10;
   prompt here nothing is expected to be found yet
   SELECT * FROM cat;
!
```

if you later want to drop and recreate the pluggable DB, do as follows (**statements commented out**)
```bash
#export DOCKER_CONTAINERNAME=OracleFree
#   $CONTAINERCMD exec -i --tty=false $DOCKER_CONTAINERNAME sqlplus -s / as sysdba <<!
#   alter pluggable database IMS close;
#   alter pluggable database IMS unplug into '/opt/oracle/oradata/ims.xml';
#   drop pluggable database IMS INCLUDING DATAFILES;
#!
```

later, when the container was shut down, restart and login as follows
```bash
$CONTAINERCMD start OracleFree
$CONTAINERCMD exec -it OracleFree sqlplus / as sysdba
```

optionally you can install the instantclient and use sqlplus from outside, but it is not necessary (**statements commented out**).
Download from [Oracle Install Client download page](https://www.oracle.com/de/database/technologies/instant-client/linux-x86-64-downloads.html)
```bash
# cd /usr/local
# mkdir instantclient
# cd instantclient
# check, if links are still correct
# wget https://download.oracle.com/otn_software/linux/instantclient/26ai/instantclient-basic-linux.x64-23.26.0.0.0.zip
# wget https://download.oracle.com/otn_software/linux/instantclient/26ai/instantclient-sqlplus-linux.x64-23.26.0.0.0.zip
# unzip instantclient-basic-linux.x64-23.3260.0.0.zip unzip instantclient-sqlplus-linux.x64-23.26.0.0.0.zip
# export PATH=$PATH:/usr/local/instantclient/instantclient_23_26
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/instantclient/instantclient_23_26
# Test call
# sqlplus sys@localhost:1521/FREEPDB1 as sysdba
```

## Troubleshoot Oracle not starting up

### too few shared memory available (e.g. after having cloned the VM)

if following error is logged when trying to call "startup" at SQL-Prompt:
> ORA-27104: system-defined limits for shared memory was misconfigured

then login in to container and adapt the limits in an Pfile:
```bash
$CONTAINERCMD exec -it $DOCKER_CONTAINERNAME bash
# you should see, that you are connected to an idle instance, when calling sqlplus
sqlplus '/ as sysdba';
CREATE PFILE='/tmp/init_temp.ora' FROM SPFILE;
quit;
# then manually edit /tmp/init_temp.ora values for "sga_target" to 1200M (use `vim`)
# and call sqlplus again and try to restart DB:
sqlplus '/ as sysdba' <<!
   STARTUP PFILE='/tmp/init_temp.ora';
!
# if this works, then make it permanently
sqlplus '/ as sysdba' <<!
CREATE SPFILE FROM PFILE='/tmp/init_temp.ora';
!
```