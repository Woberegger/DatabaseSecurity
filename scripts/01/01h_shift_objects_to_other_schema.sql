-- dynamic SQL scripts, where output can be used to shift all according objects
-- TODO: maybe find one script from a dictionary view containing all objects compared to Oracle's (user|all)_objects views)
SELECT 'ALTER TABLE '||tablename||' SET Schema dvd;'  FROM pg_catalog.pg_tables where schemaname='public';
SELECT 'ALTER VIEW '||viewname||' SET Schema dvd;'  FROM pg_catalog.pg_views where schemaname='public';
SELECT 'ALTER SEQUENCE '||sequencename||' SET Schema dvd;'  FROM pg_catalog.pg_sequences where schemaname='public';
-- for sequences, which are used for auto-increment, it is important to also modify the relationship of the owning table
SELECT 'ALTER SEQUENCE ' ||
   split_part(split_part(column_default, '''', 2), '.', 1) || '.' ||
   split_part(split_part(column_default, '''', 2), '.', 2) ||
   ' OWNED BY ' || table_schema || '.' || table_name || '.' || column_name || ';'
   FROM information_schema.columns
   WHERE column_default LIKE 'nextval%';
