##### all actions executed as user "oracle" in the database docker container #######
docker exec -it -u oracle Oracle23Free /bin/bash
# set variables
WALLET_DIR=$ORACLE_HOME/wallet
CN=db$(hostname).localdomain
PARTNERCN=client$(hostname).localdomain
WALLETPWD=WalletPasswd123

# create server-side auto-login wallet
mkdir $WALLET_DIR
orapki wallet create -wallet $WALLET_DIR -pwd $WALLETPWD -auto_login_local
# create self-signed certificate and load it into the wallet
orapki wallet add -wallet $WALLET_DIR -pwd $WALLETPWD -dn "CN=$CN" -keysize 1024 -self_signed -validity 3650
# check content of wallet
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD

# Export the certificate, so we can load it into the client wallet later.
orapki wallet export -wallet $WALLET_DIR -pwd $WALLETPWD -dn "CN=$CN" -cert /tmp/${CN}.crt
chmod a+r /tmp/${CN}.crt

# change to the previously created user "oraclient" and set the wallet there
# (for simplicity we use the client on the same system)
su - oraclient
WALLET_DIR=$HOME/wallet
WALLETPWD=WalletPasswd123
PARTNERCN=db$(hostname).localdomain
CN=client$(hostname).localdomain
mkdir $WALLET_DIR
orapki wallet create -wallet $WALLET_DIR -pwd $WALLETPWD -auto_login_local
# create a self-signed certificate for the client and load it in its wallet
orapki wallet add -wallet $WALLET_DIR -pwd $WALLETPWD -dn "CN=$CN" -keysize 1024 -self_signed -validity 3650
# check content of wallet
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD
# Export the certificate so we can load it into the server later.
orapki wallet export -wallet $WALLET_DIR -pwd $WALLETPWD -dn "CN=$CN" -cert /tmp/$CN.crt
chmod a+r  /tmp/$CN.crt

# now exchange the certificates (so we must load the certificate from the server as a trusted certificate into the client wallet and vice versa)...
orapki wallet add -wallet $WALLET_DIR -pwd $WALLETPWD -trusted_cert -cert /tmp/${PARTNERCN}.crt
# check content of client wallet again, it now includes the server certificate
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD

exit ## go back to user "oracle"
# and now add client certificate
orapki wallet add -wallet $WALLET_DIR -pwd $WALLETPWD -trusted_cert -cert /tmp/${PARTNERCN}.crt
# check content of server wallet again, it now includes the client certificate as well
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD

# then update files sqlnet.ora, listener.ora and tnsnames.ora according to the templates
# after that restart listener
lsnrctl stop
lsnrctl start
# do test connect on port 2484 (first as user "oracle")
tnsping ims_ssl

# and then adapt client
su - oraclient
cd ~/tnsadmin
cp /opt/oracle/product/23c/dbhomeFree/network/admin/sqlnet.ora .
cp /opt/oracle/product/23c/dbhomeFree/network/admin/tnsnames.ora .
# then adapt the wallet information in sqlnet.ora to where the client wallet is located
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