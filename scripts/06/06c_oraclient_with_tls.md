# DBSec06 - OracleNet with TLS encryption - client final config

*all actions executed as user "oraclient" in the database docker container*

adapt client to work with wallet
```bash
docker exec -it -u oraclient Oracle23Free /bin/bash
cd ~/tnsadmin
cp /opt/oracle/product/23ai/dbhomeFree/network/admin/sqlnet.ora .
cp /opt/oracle/product/23ai/dbhomeFree/network/admin/tnsnames.ora .
```

then adapt the wallet information in ~/tnsadmin/sqlnet.ora to where the client wallet is located
   *i.e. (DIRECTORY = /home/oraclient/wallet)*

low level test call to check, if the database is reachable with those TNS settings
```bash
tnsping ims_ssl
```

expected output of tnsping is as shown below...
>Used parameter files:<br>
>/home/oraclient/tnsadmin/sqlnet.ora
>
>Used TNSNAMES adapter to resolve the alias<br>
>Attempting to contact (DESCRIPTION = (SECURITY=(SSL_SERVER_CERT_DN=CN=db35249253d541.localdomain)) (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCPS)(HOST = localhost)(PORT = 2484))) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = IMS)))<br><br>
>OK (10 msec)

test the SSL-encrypted connection to DB:<br>
*the following login requires a password, but the select statement should not be shown in plain text anymore*

```bash
sqlplus ims/FhIms9999@IMS_SSL <<!
   select sysdate from dual;
!
```

check with tcpdump in a 2nd session and then re-execute the command above to see encrypted output
(if docker originally was exposing port 2484 to outer world, then this would work from OpenStack VM, otherwise tcpdump inside of docker container)<br>
*For installing and using tcpdump inside of oracle docker container see yum_in_oracle_container.md*

```bash
tcpdump -i any -XX -s 1024 port 2484
```