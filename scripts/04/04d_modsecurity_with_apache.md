# DBSec04 - modsecurity with apache

install necessary ModSecurity module for existing apache2 installation
```bash
sudo -s
if [ -f /etc/redhat-release ]; then
   yum install -y epel-release
   yum install -y mod_security
   # on current version of Rocky Linux the package mod_security_crs does not exist anymore, so we need to do the manual installation task
   cd /usr/share
   git clone https://github.com/coreruleset/coreruleset.git
   sudo mv coreruleset owasp-crs
   mkdir -p /etc/httpd/modsecurity.d
   # copy the example configuration to the active one
   cp /usr/share/owasp-crs/crs-setup.conf.example /etc/httpd/modsecurity.d/crs-setup.conf
   cat >/etc/httpd/modsecurity.d/owasp-crs.conf <<!
   # OWASP Core Rule Set
   IncludeOptional /usr/share/owasp-crs/rules/*.conf
!
else
   apt install -y libapache2-mod-security2
   a2enmod security2
fi
```

**on RedHat systems only:** check file `/etc/httpd/modsecurity.d/crs-setup.conf` for enabled lines like the following (should be at the end of the file):
```vim
SecAction \
    "id:900990,\
    phase:1,\
    pass,\
    t:none,\
    nolog,\
    tag:'OWASP_CRS',\
    ver:'OWASP_CRS/4.26.0-dev',\
    setvar:tx.paranoia_level=1 \
    setvar:tx.crs_setup_version=4250"
```

| Level | Description of paranoia_level|
| ----- | ---------------------------- |
| 1     | Default, low false positives |
| 2     | Stronger attack detection    |
| 3     | High security                |
| 4     | Very strict / IDS-like       |


**on RedHat systems only:** Fix SELinux Permissions (Very Important):<br>
   Without this, ModSecurity will not log or work correctly.
```bash
mkdir -p /var/lib/mod_security
chown apache:apache /var/lib/mod_security
restorecon -Rv /var/lib/mod_security
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
# first test, if configuration is valid
apachectl -t
if [ -f /etc/redhat-release ]; then
   systemctl restart httpd
else
   systemctl restart apache2
fi
```

find the new security module in same way, as we have previously enabled php - output should be:
> security2_module (shared)

```bash
if [ -f /etc/redhat-release ]; then
   httpd -M | grep security
else
   a2query -m | grep -E 'php|security'
fi
```

---

after having tested SQL injection by calling [](http://<IP-Addr>/test_sql_inj.php?id=6%20OR%201=1)
check the modsecurity log files about the detected security violation:

```bash
if [ -f /etc/redhat-release ]; then
   cat /var/log/httpd/modsec_audit.log
else
   cat /var/log/apache2/modsec_audit.log
fi
```

The expected output of the web browser should be:
>**Forbidden**<br>
>You don't have permission to access this resource.
---

if later you want to disable modsecurity again (which might make sense in next lessons), you can call the following
```bash
# better do not completely uninstall mod_security, but change `SecRuleEngine` from "On" to "DetectionOnly" or "Off"
sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' $MODSEC_CFG
if [ -f /etc/redhat-release ]; then
   #yum remove -y mod_security
   systemctl restart httpd
else
   #a2dismod security2
   systemctl restart apache2
fi
```

in order to block info.php by modsecurity, you have to do the following on RedHat systems
```bash
if [ -f /etc/redhat-release ]; then
   cat >>/etc/httpd/modsecurity.d/local_rules/modsecurity_localrules.conf <<!
# blocks access to info.php
SecRule REQUEST_URI "@contains /info.php" \
   "id:10001,phase:2,deny,status:403,log,msg:'Zugriff auf info.php blockiert'"
!
   systemctl restart httpd
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