# DBSec10 - prepare node.js version of noSqlMap

all actions on OpenStack platform as superuser
```bash
sudo -s
cd /usr/local/src
```

we first need the node.js package manager npm
```bash
apt install -y npm
```

then we download a node.js version of nosqlmap
```bash
git clone https://github.com/kardespro/nosqlmap
cd nosqlmap
npm install
npm run nsq-build
```

**TODO: the following would require a web form to fill**
```bash
npm run nsq -- --url=http://localhost:27017 --method=POST
```
 