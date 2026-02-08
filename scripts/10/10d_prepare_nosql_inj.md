# DBSec10 - noSQL injection with php

all actions on OpenStack platform as superuser
```bash
sudo -s
# start mongodb container
$CONTAINERCMD start mongodb
```

we need to install the php driver for mongodb, this is ~200-300MB and takes few minutes
a) version for Debian-based systems:
```bash
apt install -y php-pear php-dev composer
```

b) version for RedHat-based systems:
```bash
yum install -y php-pear php-dev composer
```

the questions during install can be left as the defaults
```bash
pecl install mongodb
```

optionally we could install mongoDB driver from source, but here it missing some dependencies during configure command. I do not know, what exactly
```bash
cd /usr/local/src
git clone https://github.com/mongodb/mongo-php-driver.git
cd mongo-php-driver
phpize
./configure
make all install
```

following command shows, which php.ini file is used
```bash
php --ini
# and then modify this ini file
echo "extension=mongodb.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`
```

**ATTENTION: for some reason php --ini shows wrong file - apache uses a different one**
```bash
echo "extension=mongodb.so" >> /etc/php/8.3/apache2/php.ini
cd /var/www/html/
mkdir php-quickstart
cd php-quickstart
touch quickstart.php
composer require mongodb/mongodb
```

in lecture 4 we have enabled ModSecurity WAF firewall, we should disable this again (only detect it, but to not prevent execution)
```bash
sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/modsecurity/modsecurity.conf
```

restart apache, after having changed that parameter
```bash
systemctl restart apache2
```

open following website in brower, it should show loaded module mongodb<br>
(replace "dbsecX-IP" with the IP of your openStack VM)
>[](http://<dbsecX-IP>/info.php)

copy file 10a_test_nosql_inj.php to /var/www/html/php-quickstart/, where we have the mongoDB libraries
```bash
cp ~student/DatabaseSecurity/scripts/10/10d_test_nosql_inj.php /var/www/html/php-quickstart/quickstart.php
```

then call web screen (replace "dbsecX-IP" with the IP of your openStack VM)
> [](http://<dbsecX-IP>/php-quickstart/quickstart.php)

enter injected data into form, which this window opens

in case of error check following file
```bash
tail /var/log/apache2/error.log
```