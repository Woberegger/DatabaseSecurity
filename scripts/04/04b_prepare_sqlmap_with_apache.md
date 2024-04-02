# install necessary modules for new or existing apache2 installation
sudo -s
apt-get install apache2
apt-get install php libapache2-mod-php
apt-get install php-pgsql
# check, which version is installed for following a2enmod command
apt search mod-php 
a2enmod php8.1
service apache2 reload
echo "<?php phpinfo(); ?>" > /var/www/html/info.php