-- connect to database using "psql" or "pgadmin"
SELECT current_user, session_user;
CREATE SCHEMA IF NOT EXISTS city;
SET SCHEMA 'city';
SELECT current_schema();
SET search_path TO city, public;

CREATE TABLE IF NOT EXISTS CITIES (
   name text,
   population real,
   elevation int
) tablespace pg_default;

-- create the derived table with special permissions
CREATE TABLE IF NOT EXISTS CAPITALS (
   state char(2) UNIQUE NOT NULL
) INHERITS(CITIES) tablespace pg_default;

INSERT INTO Cities VALUES ('Graz', 300000, 200);
INSERT INTO Cities VALUES ('Kapfenberg', 25000, 520);
INSERT INTO Cities VALUES ('Leoben', 28000, 550);
INSERT INTO Capitals VALUES ('Wien', 2000000, 150, 'AT');
INSERT INTO Capitals VALUES ('Berlin', 5000000, 120, 'DE');
-- this finds only the non-capital CITIES
SELECT * FROM ONLY Cities WHERE Population > 26000;
-- and this also finds the Capitals, but of course it does not show the additional column "State"
SELECT * FROM Cities WHERE Population > 26000;
-- shows all columns
SELECT * FROM Capitals;
-- what if we do a union all?
SELECT Name, Population FROM Cities UNION ALL SELECT Name, Population FROM Capitals ORDER BY Name;
-- if we now grant select to user Scott, we will see, that he only sees the cities data
GRANT USAGE, CREATE ON SCHEMA city TO Scott;
GRANT SELECT ON Cities TO Scott;
SET Role Scott;
-- user scott also sees the capitals, but he cannot select the additional column "State", as he has no permission on "Capitals"
SELECT * FROM Cities;
-- interesting is adding some column to base table, this is also inherited by all other tablespace
SET Role Postgres;
ALTER TABLE Cities ADD Major Text;
SELECT * FROM Capitals;