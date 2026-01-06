# DBSec03 - audit trigger

## installiere und aktiviere Trigger

shell script, über das der audit trigger runtergeladen, in den docker container reinkopiert
und im container ausgeführt wird.

```bash
sudo -s 
cd /tmp
git clone https://github.com/2ndQuadrant/audit-trigger
docker cp audit-trigger/audit.sql Postgres:/tmp/
# IMPORTANT: set -d parameter to switch to the correct database, where the audit schema shall be installed
docker exec -it -u postgres Postgres psql -d dvdrental -f /tmp/audit.sql
```

## verwende Trigger

Verwendung des Audit-Triggers über folgendes SQL-Script, das entweder in pgadmin
oder in docker container aufzurufen ist:
```bash
docker exec -it -u postgres Postgres psql
```
[](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/03/03b_use_audit_trigger.sql)