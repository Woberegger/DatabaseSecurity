# DBSec03 - product history

## install schema and tables

script to create schema `products` with tables, where current price and price history is stored

```bash
$CONTAINERCMD cp ~student/DatabaseSecurity/scripts/03/03c_products.sql Postgres:/tmp/
$CONTAINERCMD exec -it -u postgres Postgres psql -d ims -f /tmp/03c_products.sql
```
[](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/03/03c_products.sql)