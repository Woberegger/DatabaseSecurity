##### all actions executed as user "oraclient" in the database docker container #######
# here we want to configure our client to allow passwordless login by storing password in wallet

docker exec -it -u oraclient Oracle23Free /bin/bash
WALLET_DIR=$ORACLE_HOME/wallet
WALLETPWD=WalletPasswd123
# assume, that entry "IMS" exists in local tnsnames.ora
mkstore -wrl $HOME/wallet -createCredential IMS ims FhIms9999
orapki wallet display -wallet $WALLET_DIR -pwd $WALLETPWD

sqlplus /@IMS <<!
   select sysdate from dual;
!
# if we want to configure a 2nd DB user for passwordless login, then we need a 2nd tnsnames.ora record, e.g. IMS2
#mkstore -wrl $HOME/wallet -createCredential IMS2 <OtherDbUser> <OtherDBPassword>
