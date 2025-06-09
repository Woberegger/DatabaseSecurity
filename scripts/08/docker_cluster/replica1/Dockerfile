FROM postgres:latest
COPY recovery.sh /docker-entrypoint-initdb.d/recovery.sh
# we do this at the beginning to avoid creating of own DB in replicas, as this is skipped, when directory exists
# avoid, that for some reason there are files in that directory
RUN rm -Rf /var/lib/postgresql/data/*
# and tell system, as if currently backup is running
#RUN touch /var/lib/postgresql/data/standby.signal
# and tell by config, that this is a standby DB
#COPY postgresql.conf /var/lib/postgresql/postgresql.conf
#COPY recovery.conf /var/lib/postgresql/recovery.conf
COPY repmgr.conf /etc/repmgr.conf