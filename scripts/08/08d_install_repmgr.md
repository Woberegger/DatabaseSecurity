# DBSec08 - Postgres repmgr

install the following into the primary container pg-primary (as user root)
```bash
$CONTAINERCMD exec -it -u root pg-primary bash
```

and inside the container call:
```bash
apt-get update && apt-get install -y wget gnupg
mkdir -p /usr/share/keyrings
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install repmgr (version 18 should be existing, which matches the DB version)
apt-get update && apt-get install -y postgresql-18-repmgr

# manually create the link, which might be necessary due to different version
ln -sf /usr/bin/repmgr /usr/lib/postgresql/18/bin/

#Register primary node (for some reason this takes several minutes to succeed) - and optionally also the other ones
su - postgres -c "repmgr -f /etc/repmgr.conf primary register"
su - postgres -c "repmgr -f /etc/repmgr.conf replica1 register"
su - postgres -c "repmgr -f /etc/repmgr.conf replica2 register"
exit
```

Expected output is:
>INFO: connecting to primary database...<br>
>NOTICE: attempting to install extension "repmgr"<br>
>NOTICE: "repmgr" extension successfully installed<br>
>NOTICE: primary node record (ID: 1) registered

then with installed repmgr you should find the following 2 users in the DB
```bash
podman exec -it -u postgres pg-primary psql -c "select * from pg_catalog.pg_user;"
```
>  usename  | usesysid | usecreatedb | usesuper | userepl | usebypassrls |  passwd  | valuntil | useconfig<br>
>----------+----------+-------------+----------+---------+--------------+----------+----------+-----------<br>
> postgres |       10 | t           | t        | t       | t            | ******** |          |<br>
> replica  |    16384 | f           | f        | t       | f            | ******** |          |<br>
>(2 rows)<br>

and you should find the registered servers in following table
```bash
podman exec -it -u postgres pg-primary psql -d replica -c "SELECT node_id, node_name, type, active from repmgr.nodes;"
```