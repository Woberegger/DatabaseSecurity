# DBSec10 - noSQL preparation with node.js

all actions on OpenStack platform as superuser
```bash
sudo -s
# start mongodb container
$CONTAINERCMD start mongodb
```

*the steps for Apache can be skipped, if those were already executed in the Python noSQL injection.*

verify, if port 27017 is exposed externally
```bash
$CONTAINERCMD ps | grep mongodb | grep 27017
```
expected output similar to following one:
>2b151104eeb3   mongodb/mongodb-community-server:latest   "python3 /usr/local/…"   7 weeks ago    Up 9 minutes   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp      mongodb

in lecture 4 we have enabled ModSecurity WAF firewall, we should disable this again (only detect it, but to not prevent execution)<br>
*this should already been done in script 10a_prepare_nosql_python.md (so not explained here again)*

## install node.js

install node.js and package manager for it, then install the mongodb access package
```bash
if [ -f /etc/redhat-release ]; then
   yum install -y nodejs npm
else
   apt install -y nodejs npm
fi
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
cd ~rocky
cp ~student/DatabaseSecurity/scripts/10/10b_mongodb_connect.js .
node 10b_mongodb_connect.js
```

expected output is:

>Connected to MongoDB with authentication
>[<br>
>  {<br>
>    _id: new ObjectId('6a04da495631d37c4b8ce5b0'),<br>
>    name: 'John Doe',<br>
>    age: 25,<br>
>    course: 'IMS',<br>
>    semester: 3,<br>
>    tags: [ 'interests', 'marks' ],<br>
>    created: 'Wed May 13 2026 20:08:41 GMT+0000 (Coordinated Universal Time)'<br>
>  },<br>
>  {<br>
>    _id: new ObjectId('6a04da545631d37c4b8ce5b2'),<br>
>    name: 'Wolfgang Amadeus Mozart',<br>
>    age: 29,<br>
>    semester: 3,<br>
>    tags: [ 'music' ],<br>
>    created: 'Wed May 13 2026 20:08:52 GMT+0000 (Coordinated Universal Time)',<br>
>    course: 'Music'<br>
>  },<br>
>  {<br>
>    _id: new ObjectId('6a04df391a3e84a2734814ac'),<br>
>    name: 'Alice',<br>
>    age: 29,<br>
>    course: 'IMS',<br>
>    email: 'alice@example.com'<br>
>  }<br>
>]