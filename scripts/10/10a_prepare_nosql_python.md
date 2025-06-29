# all actions on OpenStack platform as superuser
sudo -s
# start mongodb container
docker start mongodb

# verify, if port 27017 is exposed externally
docker ps | grep mongodb | grep 27017
# expected output similar to following one:
# 2b151104eeb3   mongodb/mongodb-community-server:latest   "python3 /usr/local/…"   7 weeks ago    Up 9 minutes   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp      mongodb

# in lecture 4 we have enabled ModSecurity WAF firewall, we should disable this again (only detect it, but to not prevent execution)
sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/modsecurity/modsecurity.conf
# restart apache, after having changed that parameter
systemctl restart apache2

# install python pymongo package
apt install python3-pymongo

# test python connection to mongodb
python3 ~student/DatabaseSecurity/scripts/10/10c_mongodb_connect.py
# call the injection script
python3 ~student/DatabaseSecurity/scripts/10/10c_test_nosql_inj.py