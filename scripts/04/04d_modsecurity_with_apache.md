# install necessary ModSecurity module for existing apache2 installation
sudo -s
apt install -y libapache2-mod-security2
a2enmod security2
systemctl restart apache2
# find the new module in same way, as we have previously enabled php
a2query -m | grep -E 'php|security'
cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
# do not only detect, but even reject the SQL injection
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf
# finally restart again to be on save side, that all is considered
systemctl restart apache2
# after having tested SQL injection by calling http://<IP-Addr>/test_sql_inj.php?id=6%20OR%201=1
cat /var/log/apache/modsec_audit.log
# if later you want to disable that again, you can call
#a2dismod security2; systemctl restart apache2
