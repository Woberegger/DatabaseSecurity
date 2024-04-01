-- monitor changes in the following 3 tables
-- we do this as "postgres" user, who owns the tables
\c dvdrental
set role postgres;
SET search_path TO dvd, public;
SELECT audit.audit_table('address');
SELECT audit.audit_table('customer');
-- the update grants we already gave in previous lecture, now give also insert grants
GRANT INSERT, DELETE ON address TO objectowner;
-- even for the auto-incremented sequence we need to give rights
GRANT USAGE ON address_address_id_seq TO objectowner;
-- and now as other user we try to change some data in the tables
set role objectowner;
SET search_path TO dvd, public;
-- on select nothing happens in trigger tables, but we want to see some data, which we might want to change
select * from address limit 5;
-- this user has modification rights only on certain columns
UPDATE Address SET Address='ChangedWay', Postal_Code=8600  WHERE Address_ID=1;
INSERT INTO Address(address, district, city_id, phone, postal_code)
   VALUES ('Werk-VI-Strasse 999','Styria',463,'03862/9999','8605');
-- now when switching back to admin user we check the contents of the audit table
set role Postgres;
SELECT event_id, schema_name, table_name, relid, session_user_name, action_tstamp_tx, action_tstamp_stm, action_tstamp_clk, transaction_id, application_name, client_addr, client_port, client_query, action, row_data, changed_fields, statement_only
	FROM audit.logged_actions;