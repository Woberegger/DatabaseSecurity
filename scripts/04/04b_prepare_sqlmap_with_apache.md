# DBSec04 - prepare sqlmap with apache

install necessary modules for new or existing apache2 installation
```bash
sudo -s
apt-get install -y apache2
apt-get install -y php libapache2-mod-php
apt-get install -y php-pgsql
```

check, which php version is installed for following a2enmod command (and replace the version with output of "apt search")
```bash
apt search mod-php 
a2enmod php8.3
service apache2 reload
```
create a simple php file to show php-Information (in directory, where apache looks for html documents)
```bash
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
```