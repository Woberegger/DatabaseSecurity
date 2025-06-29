# all actions on OpenStack platform as superuser
# mongomap can be used as noSQL injection penetration test tool
cd /usr/local/src
git clone https://github.com/Hex27/mongomap.git
cd mongomap
python3 mongomap.py -u http://localhost/php-quickstart/quickstart.php --method post --data "username=admin&password=xxx"
# expected output is, that all users, which were created in script 09c_use_mongodb.md were found
 