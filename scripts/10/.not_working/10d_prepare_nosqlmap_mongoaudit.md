# DBSec10 - install mongoaudit

all actions on OpenStack platform as superuser
```bash
sudo -s
cd /usr/local/src
```

**TODO: This fails after startup screen, because maybe no graphical GUI possible**

```bash
git clone https://github.com/stampery/mongoaudit.git
cd mongoaudit
python3 setup.py install
mongoaudit --host localhost --port 27017 --user admin --password my-secret-pw --authentication-database admin
```
 