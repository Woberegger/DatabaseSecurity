FROM postgres:latest
# we cannot do this now, only after DB was once initialized
#COPY pg_hba.conf /var/lib/postgresql/18/docker/pg_hba.conf
COPY repmgr.conf /etc/repmgr.conf
# for now disabled, do steps manually
COPY init_primary.sh /docker-entrypoint-initdb.d/init_primary.sh
COPY init.sql /tmp/init.sql
USER root
RUN chmod +x /docker-entrypoint-initdb.d/init_primary.sh
RUN chmod +r /tmp/init.sql
RUN chown postgres:postgres /tmp/init.sql
USER postgres
# avoid, that for some reason there are files in that directory (paths for older 17 and newer 18 version)
RUN rm -Rf /var/lib/postgresql/18/docker/*
RUN rm -Rf /var/lib/postgresql/data/*