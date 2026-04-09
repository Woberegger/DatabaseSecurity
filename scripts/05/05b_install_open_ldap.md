# DBSec05 - preparation for OpenLdap service

## install docker container for openLdap

see howto for openLdap docker container under [](https://hub.docker.com/r/bitnami/openldap)<br>
Bitnami moved the old Debian-based images to bitnamilegacy, so without registration we have can more easy download from there (however not recommended for productive use)

```bash
$CONTAINERCMD pull docker.io/bitnamilegacy/openldap
# we use the same network as our other containers, so that we can communicate
export NETWORK=my-docker-network

$CONTAINERCMD run --name openldap \
  --network $NETWORK \
  -p 1389:1389 \
  -e LDAP_ADMIN_USERNAME=admin \
  -e LDAP_ADMIN_PASSWORD=adminpassword \
  -e LDAP_USERS=scott,customuser,otheruser,objectowner,readonly \
  -e LDAP_PASSWORDS=scotty,custompassword,otherpassword,objectownerpwd123,readonlypwd123 \
  -e LDAP_ROOT=dc=example,dc=org \
  -e LDAP_ADMIN_DN=cn=admin,dc=example,dc=org \
  -d docker.io/bitnamilegacy/openldap:latest
```

following starts the freshly created container, once it should have been stopped
```bash
$CONTAINERCMD start openldap
```

## low-level tests, that openLdap generally works

for low-level tests install the following small package ldap-utils inside of the Postgres container
(when installing it on the host you have to use localhost instead of IP address)
```bash
$CONTAINERCMD exec -it -u root Postgres /bin/bash
apt-get update
apt-get install ldap-utils
ldapsearch -x -H ldap://openldap:1389 -b 'dc=example,dc=org'
exit # leave the container
```

expected output e.g. is list of users, which we provided before in LDAP_USERS environment variable

>objectClass: groupOfNames
> 
>...
> 
>member: cn=readonly,ou=users,dc=example,dc=org

check, if explicitely the data for this user can be retrieved (you have to provide the password of user `readonly`, which is `readonly123`)
```bash
$CONTAINERCMD exec -it -u root Postgres /bin/bash
ldapsearch -H ldap://openldap:1389 -W -D "cn=readonly,ou=users,dc=example,dc=org" -b "dc=example,dc=org" "uid=readonly"
exit # leave the container
```

## adapt postgres to accept LDAP authentication

to be on the save side first copy the config file locally, so in case of a wrong record a broken container can be fixed!!!
```bash
PGDATA=$($CONTAINERCMD exec -i --tty=false -u postgres Postgres bash -c "echo \$PGDATA")
$CONTAINERCMD cp Postgres:$PGDATA/pg_hba.conf /tmp/
```

then copy the prepared file pg_hba.conf from github repo to the server
```bash
$CONTAINERCMD cp ~student/DatabaseSecurity/scripts/05/pg_hba.conf.ldap Postgres:$PGDATA/pg_hba.conf
```

start container or when already running, then better restart it, as this somehow does not seem to work: service postgresql restart
```bash
$CONTAINERCMD stop Postgres
$CONTAINERCMD start Postgres
```

in case of error when restarting the container you can call
```bash
$CONTAINERCMD logs Postgres
```

- test 1 - check, that "postgres" DB admin can still login without a password as "trusted"
```bash
$CONTAINERCMD exec -it -u postgres Postgres psql -d ims -U postgres
```

- test 2 - connect as "readonly" user using following commands (the -W parameter forces asking for password - here "readonlypwd123")<br>
           (the password to provide is not the database user's password, but the one as configured in ldap - see line 11 of script)
```bash
$CONTAINERCMD exec -it -u postgres Postgres psql -d ims -U readonly -W
```

if you should get an error as the following, then at least you know, that Ldap authentication was tried, but not successful - check the parameters or maybe you typed in a wrong password!<br>
>*psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  LDAP authentication failed for user "readonly"*

