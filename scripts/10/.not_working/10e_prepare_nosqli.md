# DBSec10 - check for possible noSQL vulnerability with nosqli

**TODO: for some reason this does not find any vulnerability**

all actions on OpenStack platform as superuser
```bash
sudo -s
apt install -y golang-go
cd /usr/local/src
wget https://github.com/Charlie-belmer/nosqli/releases/download/v0.5.4/nosqli_linux_x64_v0.5.4
mv nosqli_linux_x64_v0.5.4 /usr/local/bin/nosqli
chmod 755 /usr/local/bin/nosqli
```

test the vulnerable page
```bash
nosqli scan -t http://localhost/php-quickstart/quickstart2.php?username=admin&password=unknown
```