# DBSec02 - postgres basic security

## postgres basic permissions

Postgres basic database permission test using SQL-script using following link, which can either be called in `pgadmin` UI<br>
or directyl in docker container:
[](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/02/02b_postgres_basic_permissions.sql)

```bash
cat ~student/DatabaseSecurity/scripts/02/02b_postgres_basic_permissions.sql | $CONTAINERCMD exec -it -u postgres Postgres psql -d ims
```

## postgres table inheritance

Postgres knows the principle of table inheritance, an example can be found in following script:
[](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/02/02c_postgres_table_inheritance.sql)
```bash
cat ~student/DatabaseSecurity/scripts/02/02c_postgres_table_inheritance.sql | $CONTAINERCMD exec -it -u postgres Postgres psql -d ims
docker exec -it -u postgres Postgres psql
```
