# install sqlmap into VM or WSL
sudo -s
apt install -y python3
cd /usr/local
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
# optionally download zip archive (when git not available):
# wget -O sqlmap.zip https://github.com/sqlmapproject/sqlmap/zipball/master && unzip sqlmap.zip
