# DBSec06 - OracleNet with TLS encryption - passwordless login

*all actions executed as user "oraclient" in the database docker/podman container*

here we want to configure our client to allow passwordless login by storing password in wallet
```bash
$CONTAINERCMD exec -it -u oraclient OracleFree /bin/bash
WALLET_DIR=$HOME/wallet
WALLETPWD=WalletPasswd123
# assume, that entry "IMS" exists in local tnsnames.ora
mkstore -wrl $HOME/wallet -createCredential IMS ims FhIms9999
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD
```

**IMPORTANT:** this only works, when SQLNET.WALLET_OVERRIDE=TRUE is set in $HOME/tnsadmin/sqlnet.ora
```bash
sqlplus /@IMS <<!
   select sysdate from dual;
!
```

*if we want to configure a 2nd DB user for passwordless login, then we need a 2nd tnsnames.ora record, e.g. named IMS2<br>
(otherwise Oracle will not know, which user to use, as even the iuser name is omitted in the "sqlplus" command line)<br>
#mkstore -wrl $HOME/wallet -createCredential IMS2 <OtherDbUser> <OtherDBPassword>*
