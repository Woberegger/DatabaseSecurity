# DBSec04 - modsecurity with apache

install necessary ModSecurity module for existing apache2 installation
```bash
sudo -s
if [ -f /etc/redhat-release ]; then
   yum install -y epel-release
   yum install -y mod_security
   # TODO: does not yet work
   cd /etc/httpd/conf
   wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.5.tar.gz
   tar xzvf v3.3.5.tar.gz
   ln -s coreruleset-3.3.5 crs
   cp crs/crs-setup.conf.example crs/crs-setup.conf
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

on e.g. RockyLinux SELinux is active, which per default blocks DB connects with Apache, so this shall be disabled
```bash
if [ -f /etc/redhat-release ]; then
   setsebool -P httpd_can_network_connect_db 1
   # optionally we might generally disable SELinux (also for other tests)
   setenforce 0
fi
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
if [ -f /etc/redhat-release ]; then
   yum remove -y mod_security
   systemctl restart httpd
else
   a2dismod security2
   systemctl restart apache2
fi
```

## possible errors

in case, that the browser shows exception like "Could not connect", then try php from command line, if this works
```bash
php /var/www/html/test_sql_inj.php 6
```

the expected output should look as below, when this works
```html
<table>
        <tr>
                <td>6</td>
                <td>Jennifer</td>
                <td>Davis</td>
                <td>jennifer.davis@sakilacustomer.org</td>
        </tr>
</table>
```

so when this works, but Web page does not, then check the Httpd security settings or SELinux settings