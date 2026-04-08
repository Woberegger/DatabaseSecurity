-- creation and insert script to demonstrate analytic/window functions
\c ims
\echo create new schema products and grant creation for applicationuser role
\prompt 'Press <ENTER> to continue ...' dummy
DROP SCHEMA IF EXISTS products CASCADE;
CREATE SCHEMA products;
GRANT USAGE, CREATE ON SCHEMA products TO applicationuser;

SET role objectowner;
SET search_path TO products, public;
\echo create tables product_groups, products and product_hist
\prompt 'Press <ENTER> to continue ...' dummy
--
CREATE TABLE IF NOT EXISTS products.product_groups (
	group_id serial PRIMARY KEY,
	group_name VARCHAR (255) NOT NULL
);

CREATE TABLE IF NOT EXISTS products.products (
	product_name VARCHAR (255) PRIMARY KEY,
	group_id INT NOT NULL,
	FOREIGN KEY (group_id) REFERENCES products.product_groups (group_id)
);

CREATE TABLE IF NOT EXISTS products.product_hist (
	product_name VARCHAR (255),
	price DECIMAL (11, 2),
	valid_from DATE NOT NULL,
   valid_to DATE,
	FOREIGN KEY (product_name) REFERENCES products.products (product_name)
);
\echo insert into all 3 tables
\prompt 'Press <ENTER> to continue ...' dummy

INSERT INTO products.product_groups (group_name)
VALUES
	('Smartphone'),
	('Laptop'),
	('Tablet');

INSERT INTO products.products (product_name, group_id)
VALUES
	('Microsoft Lumia', 1),
	('HTC One', 1),
	('Nexus', 1),
	('iPhone', 1),
	('HP Elite', 2),
	('Lenovo Thinkpad', 2),
	('iPad', 3),
	('Kindle Fire', 3);
   
INSERT INTO products.product_hist (product_name, price, valid_from, valid_to)
VALUES
	('Microsoft Lumia', 500, TO_DATE('20230103','YYYYMMDD'), TO_DATE('20231201','YYYYMMDD')),
   ('Microsoft Lumia', 530, TO_DATE('20231202','YYYYMMDD'), NULL),
	('HTC One', 430, TO_DATE('20230301','YYYYMMDD'), TO_DATE('20231130','YYYYMMDD')),
   ('HTC One', 420, TO_DATE('20231130','YYYYMMDD'), TO_DATE('20231130','YYYYMMDD')),
   ('HTC One', 425, TO_DATE('20231130','YYYYMMDD'), TO_DATE('20241231','YYYYMMDD'));

--
\echo the following statement finds 2 records for HTC One, as 1 price was only valid for 1 day and has changed again during that day
\prompt 'Press <ENTER> to continue ...' dummy

SELECT product_name, Price FROM products.Product_Hist ph
   WHERE ph.valid_from = (SELECT MAX(valid_from) FROM products.Product_Hist Phmax
      WHERE phMax.product_name='HTC One');
      
-- this is the improved variant, which firstly allows to find more than 1 item and sort for more than 1 criteria, in this case
-- by additional querying the valid_to it finds the correct record
\echo this is the improved variant, which firstly allows to find more than 1 item and sort for more than 1 criteria, in this case
\echo by additional querying the valid_to it finds the correct record
\prompt 'Press <ENTER> to continue ...' dummy

SELECT product_name, Price FROM (SELECT product_name, Price,
row_number() over (partition by product_name order by valid_from DESC, valid_to DESC NULLS FIRST) AS RowN FROM products.Product_Hist)
   WHERE RowN=1;
