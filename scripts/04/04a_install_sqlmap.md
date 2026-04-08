# DBSec04 - install sqlmap

install sqlmap into openstack VM
```bash
sudo -s
if [ -f /etc/redhat-release ]; then
   yum install -y python3
else
   apt install -y python3
fi
cd /usr/local
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
# optionally download zip archive (when git not available):
# wget -O sqlmap.zip https://github.com/sqlmapproject/sqlmap/zipball/master && unzip sqlmap.zip
```