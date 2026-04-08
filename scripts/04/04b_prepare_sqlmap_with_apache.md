# DBSec04 - prepare sqlmap with apache

install necessary modules for new or existing apache2 installation
```bash
sudo -s
if [ -f /etc/redhat-release ]; then
    yum install -y httpd php php-pgsql
else
    apt-get install -y apache2 php libapache2-mod-php php-pgsql
fi
```

Debian-based systems: check, which php version is installed for following a2enmod command (and replace the version with output of "apt search")<br>
Rocky Linux: modules are not supported anymore in latest dnf version, so php-fpm shall be used instead
```bash
if [ -f /etc/redhat-release ]; then
   #yum search mod-php
   #dnf module enable php:8.3
   systemctl enable --now php-fpm
   systemctl restart httpd
   httpd -M | grep proxy_fcgi
else
   apt search mod-php
   a2enmod php8.3
   systemctl restart apache2
fi

```
create a simple php file to show php-Information (in directory, where apache looks for html documents)
```bash
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
```

test the connection to the php test page with following URL: [http://\<OpenStack-IP\>/info.php](http://<OpenStack-IP>/info.php)
