# DBSec06 - OracleNet with TLS encryption

## server certificate creation: as OS-user, under which DB runs ("oracle")
all actions executed as user "oracle" in the database docker container

```bash
docker exec -it -u oracle Oracle23Free /bin/bash
# set variables
WALLET_DIR=$ORACLE_HOME/wallet
CN=db$(hostname).localdomain
PARTNERCN=client$(hostname).localdomain
WALLETPWD=WalletPasswd123
```

*all following actions have to be done in the same docker session as user "oracle", as they use the variables from above*

create server-side auto-login wallet inside of docker container
```bash
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
exit # exit the docker container
```

## client certificate creation: as OS-user, which acts as client ("oraclient")
change to the previously created user "oraclient" and set the wallet there
(for simplicity we use the client on the same system, in a real-world example the client could be on a separate system)
```bash
docker exec -it -u oraclient Oracle23Free /bin/bash
WALLET_DIR=$HOME/wallet
WALLETPWD=WalletPasswd123
PARTNERCN=db$(hostname).localdomain
CN=client$(hostname).localdomain
mkdir $WALLET_DIR
orapki wallet create -wallet $WALLET_DIR -pwd $WALLETPWD -auto_login_local
```

*all following actions have to be done in the same docker session as user "oraclient", as they use the variables from above*

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
exit # exit the docker container
```

## client certificate loading: as OS-user, under which DB runs ("oracle")
all actions executed as user "oracle" in the database docker container

```bash
docker exec -it -u oracle Oracle23Free /bin/bash
# set variables
WALLET_DIR=$ORACLE_HOME/wallet
CN=db$(hostname).localdomain
PARTNERCN=client$(hostname).localdomain
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
docker cp listener.ora.tls.md Oracle23Free:/opt/oracle/oradata/dbconfig/FREE/listener.ora
docker cp sqlnet.ora.tls.md Oracle23Free:/opt/oracle/oradata/dbconfig/FREE/sqlnet.ora
# modify tnsnames.ora.tls.md first and then
docker cp tnsnames.ora.tls.md Oracle23Free:/opt/oracle/oradata/dbconfig/FREE/tnsnames.ora
```

after that restart listener (a potential error will be shown immediately)
```bash
lsnrctl stop
lsnrctl start
```

do test connect on port 2484 (first as user "oracle")
```bash
tnsping ims_ssl
```

continue with script 06_oraclient_with_tls.md to finally configure and test the client
