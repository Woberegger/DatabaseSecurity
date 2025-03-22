# install necessary modules for new or existing apache2 installation
sudo -s
apt-get install -y apache2
apt-get install -y php libapache2-mod-php
apt-get install -y php-pgsql
# check, which version is installed for following a2enmod command
apt search mod-php 
a2enmod php8.3
service apache2 reload
echo "<?php phpinfo(); ?>" > /var/www/html/info.php