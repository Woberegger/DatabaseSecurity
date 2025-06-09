-- create replication user on primary node and replica database istance
CREATE ROLE replica WITH REPLICATION LOGIN ENCRYPTED PASSWORD 'replica_pass';
CREATE DATABASE replica WITH OWNER replica;
SET Role replica;
\connect replica;
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