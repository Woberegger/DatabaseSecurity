# DBSec02 - postgres basic security

## postgres basic permissions

Postgres basic Datenbank permissions über folgendes SQL-Script, das entweder in pgadmin
oder in docker container aufzurufen ist:
```bash
docker exec -it -u postgres Postgres psql
```
[](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/02/02b_postgres_basic_permissions.sql)

## postgres table inheritance

Postgres kennt das Prinzip von Vererbung von Tabellen, Beispiel siehe in SQL-Script, das entweder in pgadmin
oder in docker container aufzurufen ist:
```bash
docker exec -it -u postgres Postgres psql
```
[](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/02/02c_postgres_table_inheritance.sql)