-- dynamic SQL scripts, where output can be used to shift all according objects
-- TODO: maybe find one script from a dictionary view containing all objects compared to Oracle's (user|all)_objects views)
SELECT 'ALTER TABLE '||tablename||' SET Schema dvd;'  FROM pg_catalog.pg_tables where schemaname='public';
SELECT 'ALTER VIEW '||viewname||' SET Schema dvd;'  FROM pg_catalog.pg_views where schemaname='public';
SELECT 'ALTER SEQUENCE '||sequencename||' SET Schema dvd;'  FROM pg_catalog.pg_sequences where schemaname='public';
