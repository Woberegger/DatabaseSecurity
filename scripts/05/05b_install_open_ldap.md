# DBSec05 - preparation for OpenLdap service

## install docker container for openLdap

see howto for openLdap docker container under [](https://hub.docker.com/r/bitnami/openldap)
```bash
docker pull bitnami/openldap
# we use the same network as our other containers, so that we can communicate
export NETWORK=my-docker-network

docker run --name openldap \
  --network $NETWORK \
  -p 1389:1389 \
  -e LDAP_ADMIN_USERNAME=admin \
  -e LDAP_ADMIN_PASSWORD=adminpassword \
  -e LDAP_USERS=scott,customuser,otheruser,objectowner,readonly \
  -e LDAP_PASSWORDS=scotty,custompassword,otherpassword,objectownerpwd123,readonlypwd123 \
  -e LDAP_ROOT=dc=example,dc=org \
  -e LDAP_ADMIN_DN=cn=admin,dc=example,dc=org \
  -d bitnami/openldap:latest
```

following starts the freshly created container, once it should have been stopped
```bash
docker start openldap
```

## low-level tests, that openLdap generally works

for low-level tests install the following small package ldap-utils inside of the Postgres container
(when installing it on the host you have to use localhost instead of IP address)
```bash
docker exec -it -u root Postgres /bin/bash
apt-get update
apt-get install ldap-utils
ldapsearch -x -H ldap://openldap:1389 -b 'dc=example,dc=org'
```

expected output e.g. is list of users, which we provided before

>objectClass: groupOfNames
> 
>...
> 
>member: cn=readonly,ou=users,dc=example,dc=org

check, if explicitely the data for this user can be retrieved
```bash
ldapsearch -H ldap://openldap:1389 -W -D "cn=readonly,ou=users,dc=example,dc=org" -b "dc=example,dc=org" "uid=readonly"
exit # leave docker container
```

## adapt postgres to accept LDAP authentication

to be on the save side first copy the config file locally, so in case of a wrong record a broken container can be fixed!!!
```bash
docker cp Postgres:/var/lib/postgresql/data/pg_hba.conf /tmp/
```

then copy the prepared file pg_hba.conf from github repo to the server
```bash
docker cp DatabaseSecurity/scripts/05/pg_hba.conf.ldap Postgres:/var/lib/postgresql/data/pg_hba.conf
```

start container or when already running, then better restart it, as this somehow does not seem to work: service postgresql restart
```bash
docker stop Postgres
docker start Postgres
```

in case of error when restarting the container you can call
```bash
docker logs Postgres
```

- test 1 - check, that "postgres" DB admin can still login without a password as "trusted"
```bash
docker exec -it -u postgres Postgres psql -d dvdrental
```

- test 2 - connect as "readonly" user using following commands (the -W parameter forces asking for password - here "readonlypwd123")<br>
           (the password to provide is not the database user's password, but the one as configured in ldap - see line 11 of script)
```bash
- docker exec -it -u postgres Postgres psql -d dvdrental -U readonly -W
```

if you should get an error as the following, then at least you know, that Ldap authentication was tried, but not successful - check the parameters!<br>
>*psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  LDAP authentication failed for user "readonly"*

