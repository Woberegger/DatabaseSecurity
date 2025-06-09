FROM postgres:latest
# we cannot do this now, only after DB was once initialized
#COPY pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
COPY repmgr.conf /etc/repmgr.conf
# for now disabled, do steps manually
COPY init_primary.sh /docker-entrypoint-initdb.d/init_primary.sh
COPY init.sql /docker-entrypoint-initdb.d/init.sql
RUN chmod -x /docker-entrypoint-initdb.d/init_primary.sh
# avoid, that for some reason there are files in that directory
RUN rm -Rf /var/lib/postgresql/data/*