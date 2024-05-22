# the following has to be done as root user (best in a separate docker session)
docker exec -it -u root Oracle23Free /bin/bash
useradd -g oinstall -d /home/oraclient -s /bin/bash oraclient
passwd oraclient
su - oraclient
mkdir ~/tnsadmin # here we store the client config, because of separate wallet
cat >>~/.bashrc <<!
export ORACLE_SID=FREE
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/23c/dbhomeFree
export ORACLE_DOCKER_INSTALL=true
export PATH=\$PATH:\$ORACLE_HOME/bin
export TNS_ADMIN=\$HOME/tnsadmin
!
source ~/.bashrc
exit