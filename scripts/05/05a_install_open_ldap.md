#preparation for OpenLdap service - see https://hub.docker.com/r/bitnami/openldap

docker pull bitnami/openldap
export NETWORK=my-docker-network

docker run -d --name openldap \
  --network $NETWORK \
  -p 1389:1389 \
  -p 389:389 \
  -e LDAP_ADMIN_USERNAME=admin \
  -e LDAP_ADMIN_PASSWORD=adminpassword \
  -e LDAP_USERS=customuser,objectowner,readonly \
  -e LDAP_PASSWORDS=custompassword,objectownerpwd123,readonlypwd123 \
  -e LDAP_ROOT=dc=example,dc=org \
  -e LDAP_ADMIN_DN=cn=admin,dc=example,dc=org \
  bitnami/openldap:latest
  
# following starts for once created container using
docker start openldap
# for low-level tests install the following small package
apt install ldap-utils
# the default LDAP port is 389, but the OpenLdap image is configured for the less privileged port 1389 instead
ldapsearch -x -H ldap://localhost:1389 -b 'dc=example,dc=org'
# expected output e.g. is list of users, which we provided before
#...
#objectClass: groupOfNames
#member: cn=customuser,ou=users,dc=example,dc=org
#member: cn=objectowner,ou=users,dc=example,dc=org
#member: cn=readonly,ou=users,dc=example,dc=org
#...

# adapt postgres configuration to accept LDAP authentication
echo 'host  all   all   127.0.0.1/32   ldap ldapserver=localhost ldapprefix="userid=" ldapsuffix=", cn=users, dc=example, dc=com" ldapport=1389' >>/var/lib/postgresql/data/pg_hba.conf
service postgresql restart
# or optionally stop and start container, the written record should not be deleted

