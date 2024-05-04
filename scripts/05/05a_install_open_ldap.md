#preparation for OpenLdap service - see https://hub.docker.com/r/bitnami/openldap
docker pull bitnami/openldap
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
  
# following starts the freshly created container, once it should have been stopped
docker start openldap

# for low-level tests install the following small package ldap-utils inside of the Postgres container
# (when installing it on the host you have to use localhost instead of IP address)
docker exec -it -u root Postgres /bin/bash
apt-get update
apt-get install ldap-utils
ldapsearch -x -H ldap://172.20.19.4:1389 -b 'dc=example,dc=org'
# expected output e.g. is list of users, which we provided before
#...
#objectClass: groupOfNames
#...
#member: cn=readonly,ou=users,dc=example,dc=org
#...

# check, if explicitely the data for this user can be retrieved
ldapsearch -H ldap://172.20.19.4:1389 -W -D "cn=readonly,ou=users,dc=example,dc=org" -b "dc=example,dc=org" "uid=readonly"
exit # leave docker container

# adapt postgres configuration to accept LDAP authentication
# to be on the save side first copy the config file locally, so in case of a wrong record a broken container can be fixed!!!
docker cp Postgres:/var/lib/postgresql/data/pg_hba.conf /tmp/
# then copy the prepared file pg_hba.conf from bitbucket to the server
docker cp DatabaseSecurity/scripts/05/pg_hba.conf Postgres:/var/lib/postgresql/data/pg_hba.conf
# start container or when already running, then call the following inside of the docker container
service postgresql restart
# in case of error when restarting the container you can call
docker logs Postgres

# test 1 - check, that "postgres" DB admin can still login without a password as "trusted"
docker exec -it -u postgres Postgres psql -d dvdrental
# test 2 - connect as "readonly" user using following commands (the -W parameter forces asking for password - here "readonlypwd123")
docker exec -it -u postgres Postgres psql -d dvdrental -U readonly -W
# if you should get an error as the following, then at least you know, that Ldap authentication was tried, but not successful - check the parameters!
# psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  LDAP authentication failed for user "readonly"

