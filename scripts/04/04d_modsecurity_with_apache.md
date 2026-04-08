# DBSec04 - modsecurity with apache

install necessary ModSecurity module for existing apache2 installation
```bash
sudo -s
if [ -f /etc/redhat-release ]; then
   yum install -y epel-release
   yum install -y mod_security
   systemctl restart httpd
else
   apt install -y libapache2-mod-security2
   a2enmod security2
   systemctl restart apache2
fi
```

find the new module in same way, as we have previously enabled php
```bash
if [ -f /etc/redhat-release ]; then
   httpd -M | grep security
else
   a2query -m | grep -E 'php|security'
fi
```

activate default configuration
```bash
if [ -f /etc/redhat-release ]; then
   export MODSEC_CFG=/etc/httpd/conf.d/mod_security.conf
else
   export MODSEC_CFG=/etc/modsecurity/modsecurity.conf
   cp ${MODSEC_CFG}-recommended $MODSEC_PATH
fi
```

do not only detect, but even reject the SQL injection
```bash
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' $MODSEC_CFG
```

finally restart again to be on save side, that all is considered
```bash
if [ -f /etc/redhat-release ]; then
   systemctl restart httpd
else
   systemctl restart apache2
fi
```

after having tested SQL injection by calling [](http://<IP-Addr>/test_sql_inj.php?id=6%20OR%201=1)
check the modsecurity log files about the detected security violation:

```bash
if [ -f /etc/redhat-release ]; then
   cat /var/log/httpd/modsec_audit.log
else
   cat /var/log/apache2/modsec_audit.log
fi
```

if later you want to disable modsecurity again (which might make sense in next lessons), you can call the following
```bash
a2dismod security2
systemctl restart apache2
```
