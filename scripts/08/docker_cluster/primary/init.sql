-- create replication user on primary node and replica database istance
DO $$
BEGIN
   -- avoid exception, if it should be called more than once during startup
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'replica') THEN
      CREATE ROLE replica WITH REPLICATION LOGIN ENCRYPTED PASSWORD 'replica_pass';
      CREATE DATABASE replica WITH OWNER replica;
      SET Role replica;
      CREATE SCHEMA IF NOT EXISTS repschema;
      SET SCHEMA 'repschema';
      SELECT current_schema();
      SET search_path TO repschema, public;

      CREATE TABLE IF NOT EXISTS RepTable (
         name text,
         remark text
      ) tablespace pg_default;

      INSERT INTO RepTable VALUES ('Rec1', 'first record');
      INSERT INTO RepTable VALUES ('Rec2', 'second record');

      GRANT ALL ON SCHEMA repschema TO replica;
      GRANT ALL ON repschema.RepTable TO replica;
    END IF;
END
$$;