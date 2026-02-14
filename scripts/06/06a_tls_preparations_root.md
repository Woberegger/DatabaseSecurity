# DBSec06 - preparation for Oracle TLS encryption

the following has to be executed as root user (in a docker/podman session):
create a separate OS-user, which acts as client towards DB (usually this user might exist on a separate machine than DB)
```bash
sudo -s
$CONTAINERCMD exec -it -u root OracleFree /bin/bash
useradd -g oinstall -d /home/oraclient -s /bin/bash oraclient
echo "oraclient:my-secret-pw" | chpasswd
exit
```

then we connect to the container with the created OS user "oraclient" and prepare the user's environment
```bash
$CONTAINERCMD exec -it -u oraclient OracleFree /bin/bash
mkdir ~/tnsadmin # here we store the client config, because of separate wallet
cat >>~/.bashrc <<!
export ORACLE_SID=FREE
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/26ai/dbhomeFree
export ORACLE_DOCKER_INSTALL=true
export PATH=\$PATH:\$ORACLE_HOME/bin
export TNS_ADMIN=\$HOME/tnsadmin
!
source ~/.bashrc
exit # exit docker container
```