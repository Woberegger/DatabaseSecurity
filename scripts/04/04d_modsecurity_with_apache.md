# DBSec04 - modsecurity with apache

install necessary ModSecurity module for existing apache2 installation
```bash
sudo -s
apt install -y libapache2-mod-security2
a2enmod security2
systemctl restart apache2
```

find the new module in same way, as we have previously enabled php
```bash
a2query -m | grep -E 'php|security'
```

activate default configuration
```bash
cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
```

do not only detect, but even reject the SQL injection
```bash
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf
```

finally restart again to be on save side, that all is considered
```bash
systemctl restart apache2
```

after having tested SQL injection by calling [](http://<IP-Addr>/test_sql_inj.php?id=6%20OR%201=1)
check the modsecurity log files about the detected security violation:

```bash
cat /var/log/apache2/modsec_audit.log
```

if later you want to disable modsecurity again (which might make sense in next lessons), you can call the following
```bash
a2dismod security2
systemctl restart apache2
```
