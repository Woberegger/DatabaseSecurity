# DBSec10 - NoSQL injection with Python

all actions on OpenStack platform as superuser
```bash
sudo -s
# start mongodb container
$CONTAINERCMD start mongodb
```

verify, if port 27017 is exposed externally
```
$CONTAINERCMD ps | grep mongodb | grep 27017
```
expected output should be similar to following one:
>2b151104eeb3   mongodb/mongodb-community-server:latest   "python3 /usr/local/…"   7 weeks ago    Up 9 minutes   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp      mongodb

in lecture 4 we have enabled ModSecurity WAF firewall, we should disable this again (only detect it, but to not prevent execution)
(if nginx is used, see necessary changes to be undone for nginx in lecture 4)
```bash
if [ -f /etc/redhat-release ]; then
   export MODSEC_CFG=/etc/httpd/conf.d/mod_security.conf
else
   export MODSEC_CFG=/etc/modsecurity/modsecurity.conf
fi
sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' $MODSEC_CFG
```

restart apache, after having changed that parameter
```bash
apachectl -t
if [ -f /etc/redhat-release ]; then
   systemctl restart httpd
else
   systemctl restart apache2
fi
```

install python pymongo package
```bash
if [ -f /etc/redhat-release ]; then
   yum install -y python3-pymongo
else
   apt install -y python3-pymongo
fi
```

test python connection to mongodb
```bash
python3 ~student/DatabaseSecurity/scripts/10/10a_mongodb_connect.py
```

expected result is:
> ✅ Connected successfully to MongoDB.

call the injection script
```bash
python3 ~student/DatabaseSecurity/scripts/10/10a_test_nosql_inj.py
```

expected result is:
> Login bypassed! Found user: {'_id': ObjectId('....'), 'username': 'admincopy', 'password': 'secret'}