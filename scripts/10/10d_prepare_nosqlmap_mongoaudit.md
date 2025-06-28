# all actions on OpenStack platform as superuser
cd /usr/local/src

# TODO: This fails after startup screen, because maybe no graphical GUI possible
git clone https://github.com/stampery/mongoaudit.git
cd mongoaudit
python3 setup.py install
mongoaudit --host localhost --port 27017 --user admin --password my-secret-pw --authentication-database admin
 