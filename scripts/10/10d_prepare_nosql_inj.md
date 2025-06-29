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
# for some reason php --ini shows wrong file - apache uses a different one
echo "extension=mongodb.so" >> /etc/php/8.3/apache2/php.ini
cd /var/www/html/
mkdir php-quickstart
cd php-quickstart
touch quickstart.php
composer require mongodb/mongodb

# in lecture 4 we have enabled ModSecurity WAF firewall, we should disable this again (only detect it, but to not prevent execution)
sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/modsecurity/modsecurity.conf
# restart apache, after having changed that parameter
systemctl restart apache2

# open following website in brower, it should show loaded module mongodb
http://<dbsecX>/info.php

#copy file 10a_test_nosql_inj.php to /var/www/html/php-quickstart/, where we have the mongoDB libraries
cp ~student/DatabaseSecurity/scripts/10/10a_test_nosql_inj.php /var/www/html/php-quickstart/quickstart.php

# then call web screen http://<dbsecX-IP>/php-quickstart/quickstart.php
# enter injected data into form

# in case of error check following file 
tail /var/log/apache2/error.log