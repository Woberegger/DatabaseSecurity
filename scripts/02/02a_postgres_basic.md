# DBSec02 - postgres basic security

## postgres basic permissions

Postgres basic database permission test using SQL-script using following link, which can either be called in `pgadmin` UI<br>
or directly in docker/podman container:
[](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/02/02b_postgres_basic_permissions.sql)

```bash
sudo -s
cat ~student/DatabaseSecurity/scripts/02/02b_postgres_basic_permissions.sql | $CONTAINERCMD exec -i --tty=false -u postgres Postgres psql
```

## postgres table inheritance

Postgres knows the principle of table inheritance, an example can be found in following script:
[](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/02/02c_postgres_table_inheritance.sql)
```bash
sudo -s
cat ~student/DatabaseSecurity/scripts/02/02c_postgres_table_inheritance.sql | $CONTAINERCMD exec -i --tty=false -u postgres Postgres psql
```
