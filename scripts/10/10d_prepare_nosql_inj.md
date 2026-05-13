# DBSec10 - noSQL injection with php

all actions on OpenStack platform as superuser
```bash
sudo -s
# start mongodb container
$CONTAINERCMD start mongodb
```

we need to install the php driver for mongodb, this is ~200-300MB and takes few minutes
```bash
if [ -f /etc/redhat-release ]; then
   yum install -y php-pear php-devel composer libbson-devel
else
   apt install -y php-pear php-dev composer
fi
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
if [ ! -f /etc/redhat-release ]; then
   # and then modify this ini file
   echo "extension=mongodb.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`
fi
```

**ATTENTION: on Debian for some reason php --ini shows wrong file - apache uses a different one**
```bash
if [ -f /etc/redhat-release ]; then
   echo "extension=mongodb.so" >/etc/php.d/20-mongodb.ini
   systemctl restart httpd
   # this one controls the php modules
   systemctl restart php-fpm
else
   echo "extension=mongodb.so" >> /etc/php/8.3/apache2/php.ini
   systemctl restart apache2
   systemctl restart php-fpm
fi
cd /var/www/html/
mkdir php-quickstart
cd php-quickstart
touch quickstart.php
composer require mongodb/mongodb
```

in lecture 4 we have enabled ModSecurity WAF firewall, we should disable this again (only detect it, but to not prevent execution)<br>
*this should already been done in script 10a_prepare_nosql_python.md (so not explained here again)*

open following website in brower, it should show loaded module mongodb<br>
(replace "dbsecX-IP" with the IP of your openStack VM)
>[](http://<dbsecX-IP>/info.php)
(if info.php should be missing, see lecture 4, how this should look like and where you should store it)

copy file 10d_test_nosql_inj.php to /var/www/html/php-quickstart/, where we have the mongoDB libraries
```bash
cp ~student/DatabaseSecurity/scripts/10/10d_test_nosql_inj.php /var/www/html/php-quickstart/quickstart.php
cp ~student/DatabaseSecurity/scripts/10/10d_test_nosql_inj_json.php /var/www/html/php-quickstart/quickstart_json.php
```

then call web screen (replace "dbsecX-IP" with the IP of your openStack VM)
> [](http://<dbsecX-IP>/php-quickstart/quickstart.php)

enter first correct data into form - this should return `Welcome, John Doe!`
>Student: John Doe<br>
>Course: IMS

then enter injected data into form, like:
>Student: { "$ne": null }<br>
>Course: { "$ne": null }

**IMPORTANT: this somehow does not work, but later the Mongomap tool properly finds out, how to inject the parameters ...**

use curl for json inputs from command line, this should also find the first Music student, which is `Wolfgang Amadeus Mozart` ...
```bash
curl -X POST http://localhost/php-quickstart/quickstart_json.php -H "Content-Type: application/json" -d '{"name": {"$ne": null}, "course": "Music"}'
```

in case of error check following file
```bash
if [ -f /etc/redhat-release ]; then
   tail /var/log/httpd/error_log
else
   tail /var/log/apache2/error.log
fi
```