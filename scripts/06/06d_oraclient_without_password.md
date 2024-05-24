##### all actions executed as user "oraclient" in the database docker container #######
# here we want to configure our client to allow passwordless login by storing password in wallet

docker exec -it -u oraclient Oracle23Free /bin/bash
# assume, that entry "IMS" exists in local tnsnames.ora
mkstore -wrl $HOME/wallet -createCredential IMS ims FhIms2024
sqlplus @IMS <<!
   select sysdate from dual;
!
# if we want to configure a 2nd DB user for passwordless login, then we need a 2nd tnsnames.ora record, e.g. IMS2
#mkstore -wrl $HOME/wallet -createCredential IMS2 <OtherDbUser> <OtherDBPassword>
