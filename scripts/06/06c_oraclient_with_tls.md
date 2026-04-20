# DBSec06 - OracleNet with TLS encryption - client final config

*all actions executed as user "oraclient" in the database docker/podman container*

adapt client to work with wallet
```bash
$CONTAINERCMD exec -it -u oraclient OracleFree /bin/bash
cd ~/tnsadmin
cp /opt/oracle/oradata/dbconfig/FREE/sqlnet.ora .
cp /opt/oracle/oradata/dbconfig/FREE/tnsnames.ora .
```

then manually adapt the wallet information in ~/tnsadmin/sqlnet.ora to where the client wallet is located
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

check with tcpdump from the host container
(this is better than installing tcpdump inside of the `OracleFree` container, as this needs to install lots of additional packages, which might hang!!!)<br>
~~For installing and using tcpdump inside of oracle container see yum_in_oracle_container.md~~

```bash
# determine PID of our container
PID=$(podman inspect --format '{{.State.Pid}}' OracleFree)
# then we enter the container's namespace by its PID and do the tcpdump there
nsenter -n -t $PID tcpdump -i any -XX -s 1024 port 2484
```

expected result is, that we should not find any plain text in our tcpdump!