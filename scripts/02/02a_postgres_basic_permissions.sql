-- check, if we are really the administrative user "postgres"
SELECT current_user, session_user;
SELECT current_schema();
CREATE ROLE ApplicationUser WITH CREATEDB;
CREATE USER ObjectOwner PASSWORD 'my-secret-pw' IN ROLE ApplicationUser; 
CREATE USER ReadOnly WITH Login CONNECTION LIMIT 1 PASSWORD 'read-only-pw';
-- we need to create a schema, where the new users are allowed to create their objects
CREATE SCHEMA dvd;
GRANT USAGE, CREATE ON SCHEMA dvd TO ApplicationUser;
--
SET Role Scott;
-- now see difference in output between current_user and session_user (here the one, which owns the objects)
SELECT current_user, session_user;
-- switch to the proper database, where our objects reside
\c dvdrental
-- describe one of the tables to see, if they exist
\d customer
-- and create a view on those tables, which we want to grant
CREATE OR REPLACE VIEW customer_list
AS
SELECT cu.customer_id AS id,
    (((cu.first_name)::text || ' '::text) || (cu.last_name)::text) AS name,
    a.address,
    a.postal_code AS "zip code",
    a.phone,
    city.city,
    country.country,
        CASE
            WHEN cu.activebool THEN 'active'::text
            ELSE ''::text
        END AS notes,
    cu.store_id AS sid
   FROM (((customer cu
     JOIN address a ON ((cu.address_id = a.address_id)))
     JOIN city ON ((a.city_id = city.city_id)))
     JOIN country ON ((city.country_id = country.country_id)));
--
\d customer_list
GRANT SELECT ON customer_list TO ReadOnly;
GRANT SELECT ON customer, address, city, country, customer_list TO ObjectOwner;
-- allow to change certain columns in 2 tables, try it either using the table or the view
GRANT UPDATE (address, postal_code, city_id) ON address TO ObjectOwner;
GRANT UPDATE (country) ON country TO ObjectOwner;

-- now try with the read-only user
SET Role ReadOnly;
-- the describe command works, as before we have already switched to that database
\d customer_list;
SELECT * FROM Customer_List LIMIT 5;
-- the following is expected to fail because of missing permissions
SELECT * FROM Address LIMIT 3;
-- # ERROR:  permission denied for table address

-- now we try the user "ObjectOwner" ...
SET Role ObjectOwner;
-- try to first find objects in dvd schema
SET search_path TO dvd, public;
-- the describe command works, as before we have already switched to that database
\d customer_list;
\d address;
-- the following fails, as the view is too complex to update it directly
UPDATE Customer_List SET Address='Testweg 1' WHERE ID=524;
--#ERROR:  cannot update view "customer_list"
--#DETAIL:  Views that do not select from a single table or view are not automatically updatable.
--#HINT:  To enable updating the view, provide an INSTEAD OF UPDATE trigger or an unconditional ON UPDATE DO INSTEAD rule.
-- so we try the direct update
UPDATE Address SET Address='Testweg 1', Postal_Code=8605  WHERE Address_ID=1;
-- create a more simple view in the schema "dvd", where the user is allowed to create objects
CREATE OR REPLACE VIEW dvd.customer_list_updateable
AS
SELECT cu.customer_id AS id,
    cu.first_name,
    cu.last_name,
    a.address,
    a.postal_code AS "zip code",
    a.phone,
    city.city,
    country.country,
    cu.activebool,
    cu.store_id AS sid
   FROM (((customer cu
     JOIN address a ON ((cu.address_id = a.address_id)))
     JOIN city ON ((a.city_id = city.city_id)))
     JOIN country ON ((city.country_id = country.country_id)));
-- and now try the update again - does it still fail? What can we do about that?
UPDATE dvd.customer_list_updateable SET Address='Testweg 2' WHERE ID=524;