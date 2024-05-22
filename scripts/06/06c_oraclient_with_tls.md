##### all actions executed as user "oraclient" in the database docker container #######
# adapt client to work with wallet
docker exec -it -u oraclient Oracle23Free /bin/bash
cd ~/tnsadmin
cp /opt/oracle/product/23c/dbhomeFree/network/admin/sqlnet.ora .
cp /opt/oracle/product/23c/dbhomeFree/network/admin/tnsnames.ora .
# then adapt the wallet information in ~/tnsadmin/sqlnet.ora to where the client wallet is located
# i.e. (DIRECTORY = /home/oraclient/wallet)

# expected output is as shown below...
tnsping ims_ssl
### ...
### Used parameter files:
### /home/oraclient/tnsadmin/sqlnet.ora
### 
### Used TNSNAMES adapter to resolve the alias
### Attempting to contact (DESCRIPTION = (SECURITY=(SSL_SERVER_CERT_DN=CN=db35249253d541.localdomain)) (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCPS)(HOST = localhost)(PORT = 2484))) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = IMS)))
### OK (10 msec)

sqlplus ims/FhIms2024@IMS_SSL <<!
   select sysdate from dual;
!