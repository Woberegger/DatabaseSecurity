# DBSec03 - audit trigger

## install and activate trigger

script to download the audit trigger, copy it into the running docker container<br>
and execute it there to install it into the Postgres database

```bash
sudo -s 
cd /tmp
git clone https://github.com/2ndQuadrant/audit-trigger
$CONTAINERCMD cp audit-trigger/audit.sql Postgres:/tmp/
# IMPORTANT: set -d parameter to switch to the correct database, where the audit schema shall be installed
$CONTAINERCMD exec -it -u postgres Postgres psql -d ims -f /tmp/audit.sql
```

## use audit trigger

the use do the audit trigger can be shown via the following script, which you can either call in GUI like `pgadmin`<br>
or in `psql` command line with following syntax:<br>
(we better first copy the script into the container, so that we can call it with `-f` parameter and use the \prompt commands to step through the script)
```bash
$CONTAINERCMD cp ~student/DatabaseSecurity/scripts/03/03b_use_audit_trigger.sql Postgres:/tmp/
$CONTAINERCMD exec -it -u postgres Postgres psql -d ims -f /tmp/03b_use_audit_trigger.sql
```
[](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/03/03b_use_audit_trigger.sql)