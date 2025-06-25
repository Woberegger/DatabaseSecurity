# all actions on OpenStack platform as superuser
sudo -s
# start mongodb container
docker start mongodb

# verify, if port 27017 is exposed externally
docker ps | grep mongodb | grep 27017
# expected output similar to following one:
# 2b151104eeb3   mongodb/mongodb-community-server:latest   "python3 /usr/local/…"   7 weeks ago    Up 9 minutes   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp      mongodb

# we need to install the php driver for mongodb, this is ~200-300MB and takes few minutes
apt install -y php-pear php-dev composer
# the questions during install can be left as the defaults
pecl install mongodb

# optionally we could install mongoDB driver from source, but here it missing some dependencies during configure command. I do not know, what exactly
## cd /usr/local/src
## git clone https://github.com/mongodb/mongo-php-driver.git
## cd mongo-php-driver
## phpize
## ./configure
## make all install

# following command show, which php.ini file is used
php --ini

echo "extension=mongodb.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`

cd /var/www/html/
mkdir php-quickstart
cd php-quickstart
touch quickstart.php
composer require mongodb/mongodb

#copy file test_nosql_inj.php to /var/www/html/
cp ~student/DatabaseSecurity/scripts/10/10a_test_nosql_inj.php /var/www/html

# in lecture 4 we have enabled ModSecurity WAF firewall, we should disable this again (only detect it, but to not prevent execution)
sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/modsecurity/modsecurity.conf
# restart apache, after having changed that parameter
systemctl restart apache2

# then call web screen http://<dbsecX-IP>/10a_test_nosql_inj.php
apt install -y nodejs npm
npm install mongodb

# the output should show a lot of Mongo... and other methods
node <<!
   const mongodb = require('mongodb');
   console.log(mongodb);
!
