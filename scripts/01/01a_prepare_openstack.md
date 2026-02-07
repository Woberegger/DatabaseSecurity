# DBSec01 - prepare OpenStack

## a) for Debian-based systems: necessary tools missing in default in stallation

```bash
apt -y install inetutils-telnet
apt -y install nmap
apt -y install curl
apt -y install wget
apt -y install vim
apt -y install vim-gtk3 # necessary on Debian image, where vim is built without clipboard support ("vim --version | grep clipboard")
apt -y install net-tools
apt -y install git
apt -y install wireshark
apt -y install gpg # needed for apt keys to add
```

## b) for RedHat-based systems: necessary tools missing in default in stallation

```bash
yum -y install inetutils-telnet
yum -y install nmap
yum -y install curl
yum -y install wget
yum -y install vim
yum -y install net-tools
yum -y install git
yum -y install wireshark
yum -y install gpg # needed for apt keys to add
```

in order to already prepare the git environment, we create the user before cloning
```bash
useradd -m -s /bin/bash -g users student
```

and then we already clone the git environment for the lecture scripts
```bash
su - student
git clone https://github.com/Woberegger/DatabaseSecurity
```