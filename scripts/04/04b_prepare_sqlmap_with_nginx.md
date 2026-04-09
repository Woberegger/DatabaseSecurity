# DBSec04 - prepare sqlmap with nginx

I recommend to use apache, as this is easier to configure for our purposes, although nginx might be the more modern web server

install and prepare nginx WebServer for use with sqlmap
```bash
sudo -s
if [ -f /etc/redhat-release ]; then
   yum install -y nginx
else
   apt install -y nginx
fi
```
or use separate docker container (in that case configuration needs to be done in the docker container, which shall then be saved to image)
```bash
docker pull nginx
```
install FastCGI Process Manager
```bash
if [ -f /etc/redhat-release ]; then
   systemctl enable --now php-fpm
   systemctl status php-fpm
else
   apt install php8.1-fpm
   systemctl status php8.1-fpm
fi
```

**!!! IMPORTANT !!!**
do following adapations to file /etc/nginx/sites-available/default
according to sample config part in file [](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/04/04c_nginx_config_file.conf)

validate config file - this should not show any errors
```bash
nginx -t
systemctl restart nginx
```
---

create a simple php file to show php-Information (in directory, where apache looks for html documents)
```bash
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
```

test the connection to the php test page with following URL: [http://\<OpenStack-IP\>/info.php](http://<OpenStack-IP>/info.php)<br>
You should get the output, that php is working, version info etc.

copy the SQL-injection test file to our webserver directory
```bash
cp ~student/DatabaseSecurity/scripts/04/test_sql_inj.php /var/www/html/
```
---

then call sqlmap to find out about vulnerabilities of the web page. And you will see at the end lots of infos about our database schema, extracted from that single vulnerable web page!!!
```bash
cd /usr/local/sqlmap-dev
python3 sqlmap.py -u "http://localhost/test_sql_inj.php?id=51" --tables --flush-session
```