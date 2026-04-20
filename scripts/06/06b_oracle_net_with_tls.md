# DBSec06 - OracleNet with TLS encryption

## server certificate creation: as OS-user, under which DB runs ("oracle")
all actions executed as user "oracle" in the database docker container

```bash
$CONTAINERCMD exec -it -u oracle OracleFree /bin/bash
# set variables
export WALLET_DIR=$ORACLE_HOME/wallet
export CN=db$(hostname).localdomain
export PARTNERCN=client$(hostname).localdomain
WALLETPWD=WalletPasswd123
```

*all following actions have to be done in the same docker session as user "oracle", as they use the variables from above*

create server-side auto-login wallet inside of docker/podman container
```bash
cd $ORACLE_HOME
mkdir $WALLET_DIR
orapki wallet create -wallet $WALLET_DIR -pwd $WALLETPWD -auto_login_local
```

create a self-signed certificate for the client and load it into the wallet
```bash
orapki wallet add -wallet $WALLET_DIR -pwd $WALLETPWD -dn "CN=$CN" -keysize 1024 -self_signed -validity 3650
```

check content of wallet
```bash
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD
```

Export the certificate, so we can load it into the client wallet later.
```bash
orapki wallet export -wallet $WALLET_DIR -pwd $WALLETPWD -dn "CN=$CN" -cert /tmp/${CN}.crt
chmod a+r /tmp/${CN}.crt
exit # exit the container
```

## client certificate creation: as OS-user, which acts as client ("oraclient")
change to the previously created user "oraclient" and set the wallet there
(for simplicity we use the client on the same system, in a real-world example the client could be on a separate system)
```bash
$CONTAINERCMD exec -it -u oraclient OracleFree /bin/bash
export WALLET_DIR=$HOME/wallet
WALLETPWD=WalletPasswd123
export PARTNERCN=db$(hostname).localdomain
export CN=client$(hostname).localdomain
mkdir $WALLET_DIR
orapki wallet create -wallet $WALLET_DIR -pwd $WALLETPWD -auto_login_local
```

*all following actions have to be done in the same docker/podman session as user "oraclient", as they use the variables from above*

create a self-signed certificate for the client and load it in its wallet
```bash
orapki wallet add -wallet $WALLET_DIR -pwd $WALLETPWD -dn "CN=$CN" -keysize 1024 -self_signed -validity 3650
```

check content of wallet
```bash
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD
```
Export the certificate so we can load it into the server later.
```bash
orapki wallet export -wallet $WALLET_DIR -pwd $WALLETPWD -dn "CN=$CN" -cert /tmp/$CN.crt
chmod a+r  /tmp/$CN.crt
```

now exchange the certificates (so we must load the certificate from the server as a trusted certificate into the client wallet and vice versa)...
```bash
orapki wallet add -wallet $WALLET_DIR -pwd $WALLETPWD -trusted_cert -cert /tmp/${PARTNERCN}.crt
```

check content of client wallet again, it now includes the server certificate
```bash
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD
exit # exit the container
```

## client certificate loading: as OS-user, under which DB runs ("oracle")
all actions executed as user "oracle" in the database docker container

```bash
$CONTAINERCMD exec -it -u oracle OracleFree /bin/bash
# set variables
export WALLET_DIR=$ORACLE_HOME/wallet
export CN=db$(hostname).localdomain
export PARTNERCN=client$(hostname).localdomain
WALLETPWD=WalletPasswd123
```

*all following actions have to be done in the same docker session as user "oracle", as they use the variables from above*

now add client certificate
```bash
orapki wallet add -wallet $WALLET_DIR -pwd $WALLETPWD -trusted_cert -cert /tmp/${PARTNERCN}.crt
```
check content of server wallet again, it now includes the client certificate as well
```bash
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD
exit # exit from container
```

**IMPORTANT:**<br>
then update files in /opt/oracle/oradata/dbconfig/FREE directory:<br>
- sqlnet.ora
- listener.ora
- tnsnames.ora<br>
according to the templates named \*.tls"<br>
the following line in tnsnames.ora has to be changed before to what the command<br>

>orapki wallet display \$WALLET_DIR -pwd \$WALLETPWD<br>

tells us, whereas the other 2 files can be copied without changes<br>
 e.g.:   (SECURITY=(SSL_SERVER_CERT_DN="CN=db365169eb3fe6.localdomain"))

```bash
$CONTAINERCMD cp ~student/DatabaseSecurity/scripts/06/listener.ora.tls OracleFree:/opt/oracle/oradata/dbconfig/FREE/listener.ora
$CONTAINERCMD cp ~student/DatabaseSecurity/scripts/06/sqlnet.ora.tls OracleFree:/opt/oracle/oradata/dbconfig/FREE/sqlnet.ora
# either modify tnsnames.ora.tls first and then copy it (or change it with "vi" inside of the container)
$CONTAINERCMD cp ~student/DatabaseSecurity/scripts/06/tnsnames.ora.tls OracleFree:/opt/oracle/oradata/dbconfig/FREE/tnsnames.ora
```

after that restart listener (a potential error will be shown immediately)
```bash
$CONTAINERCMD exec -it -u oracle OracleFree /bin/bash
lsnrctl stop
lsnrctl start
```

do test connect on port 2484 (first as user "oracle")
```bash
tnsping ims_ssl
```

continue with script 06_oraclient_with_tls.md to finally configure and test the client
