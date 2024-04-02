# install and prepare nginx WebServer for use with sqlmap
sudo -s
apt-get install nginx
# or use: docker pull nginx (in that case configuration needs to be done in the docker container, which shall then be saved to image)
apt-get install php8.1-fpm
systemctl status php8.1-fpm
# IMPORTANT: do following adapations to /etc/nginx/sites-available/default
### see sample config part in file 04c_nginx_config_file.md
# validate config file - this should not show any errors
nginx -t
systemctl restart nginx
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
