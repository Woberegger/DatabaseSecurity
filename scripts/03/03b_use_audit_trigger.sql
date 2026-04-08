-- monitor changes in the 3 tables with audit_trigger in IMS database
\c ims
\echo monitor changes in tables: address, customer
\echo we do this as "postgres" user, who owns the tables
set role postgres;
\echo we set search path to "dvd, public", so that we do not always need to provide the schema prefix
SET search_path TO dvd, public;
\echo enable auditing on address and customer table
\prompt 'Press <ENTER> to continue ...' dummy
SELECT audit.audit_table('address');
SELECT audit.audit_table('customer');
\echo the update grants an "address" we re-do from previous lecture (on certain columns only), now we give also select/insert/delete grants to objectowner
\prompt 'Press <ENTER> to continue ...' dummy
GRANT SELECT, INSERT, DELETE ON address TO objectowner;
GRANT UPDATE (address, postal_code, city_id) ON address TO objectowner;
\echo even for the auto-increment sequence we need to give rights
GRANT USAGE ON address_address_id_seq TO objectowner;
\echo and now as user "objectowner" we try to change some data in the tables
\prompt 'Press <ENTER> to continue ...' dummy
set role objectowner;
SET search_path TO dvd, public;
\echo on select from address nothing happens in trigger tables, but we want to see some data, which we might want to change
\prompt 'Press <ENTER> to continue ...' dummy
select * from address limit 5;
\echo this user has modification rights only on all involved columns, so the following update should work
\prompt 'Press <ENTER> to continue ...' dummy
UPDATE Address SET Address='ChangedWay', Postal_Code=8600  WHERE Address_ID=1;
\echo and with insert permissions the insert into addresses should be accepted
\prompt 'Press <ENTER> to continue ...' dummy
INSERT INTO Address(address, district, city_id, phone, postal_code)
   VALUES ('Werk-VI-Strasse 999','Styria',463,'03862/9999','8605');
\echo now when switching back to administrative user "Postgres" we check the contents of the audit table
\prompt 'Press <ENTER> to continue ...' dummy
set role Postgres;
SELECT event_id, schema_name, table_name, relid, session_user_name, action_tstamp_tx, action_tstamp_stm, action_tstamp_clk, transaction_id, application_name, client_addr, client_port, client_query, action, row_data, changed_fields, statement_only
	FROM audit.logged_actions;
\echo "expected result: the update and insert should both have been logged"