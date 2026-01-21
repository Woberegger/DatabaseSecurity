# DBSec10 - noSQL preparation with node.js

all actions on OpenStack platform as superuser
```bash
sudo -s
# start mongodb container
docker start mongodb
```

*the steps for Apache can be skipped, if those were already executed in the Python noSQL injection.*

verify, if port 27017 is exposed externally
```bash
docker ps | grep mongodb | grep 27017
```
expected output similar to following one:
>2b151104eeb3   mongodb/mongodb-community-server:latest   "python3 /usr/local/…"   7 weeks ago    Up 9 minutes   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp      mongodb

in lecture 4 we have enabled ModSecurity WAF firewall, we should disable this again (only detect it, but to not prevent execution)
```bash
sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/modsecurity/modsecurity.conf
```

restart apache, after having changed that parameter
```bash
systemctl restart apache2
```

## install node.js

install node.js and package manager for it
```bash
apt install -y nodejs npm
npm install mongodb
```

the output should show a lot of Mongo... and other methods
```bash
node <<!
   const mongodb = require('mongodb');
   console.log(mongodb);
!
```

then call connection test 10b_mongodb_connect.js
```bash
cp ~student/DatabaseSecurity/scripts/10/10b_mongodb_connect.js .
node 10b_mongodb_connect.js
```
