-- connect to database as sys user, e.g. docker exec -it -u oracle OracleFree sqlplus 'sys/FhIms9999@IMS as sysdba'
ALTER session SET container=IMS;
select value from v$option where parameter like '%Label%';
-- if this says "FALSE, then run following script
@?/rdbms/admin/catols.sql
-- and the user needs to be unlocked (in the CDB, not inside any of the containers)
ALTER SESSION SET CONTAINER = CDB$ROOT;
ALTER USER LBACSYS DISABLE DICTIONARY PROTECTION;
ALTER USER LBACSYS IDENTIFIED BY FhIms9999 ACCOUNT UNLOCK CONTAINER=ALL;
-- switch back into the PDB
ALTER session SET container=IMS;
-- register the OLS-Framework inside of our container
EXEC LBACSYS.CONFIGURE_OLS;
-- activate forcing of OLS functions
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
-- check, if label security is really enabled (both values should be "TRUE")
SELECT Name, Status FROM DBA_OLS_STATUS;
--
-- even SYS per default is not allowed to create the policies, this only works with separate user inside the PDB
--
CREATE USER Sec_Admin IDENTIFIED BY FhIms9999;
GRANT DBA TO Sec_Admin;
GRANT EXECUTE ON SA_SYSDBA TO Sec_Admin;
GRANT EXECUTE ON SA_LABEL_ADMIN TO Sec_Admin;
GRANT EXECUTE ON SA_USER_ADMIN TO Sec_Admin;
GRANT EXECUTE ON SA_POLICY_ADMIN TO Sec_Admin;
-- and separate OLS privileges are needed, even SA_SYSDBA does not suffice in order to allow to create a policy!
GRANT LBAC_DBA TO Sec_Admin WITH ADMIN OPTION;

GRANT INHERIT PRIVILEGES ON USER LBACSYS TO Sec_Admin;

CONNECT Sec_Admin/FhIms9999@IMS;
--
BEGIN
  SA_SYSDBA.CREATE_POLICY(
    policy_name     => 'emp_policy',
    column_name     => 'sec_label',
    default_options => 'READ_CONTROL,WRITE_CONTROL'
  );
END;
/
-- we add a "sec_label" column to existing EMP table
-- possible values are:
-- 1000 'NORMAL'
-- 1001 'CONFIDENTIAL'
-- 1002 'SECRET'

CONNECT SCOTT/tiger@IMS;
ALTER TABLE SCOTT.EMP ADD (SEC_LABEL NUMBER DEFAULT 1001);
UPDATE SCOTT.EMP SET Sec_Label=CASE WHEN DeptNo=10 THEN 1002
                                    WHEN JOB='PRESIDENT' THEN 1002
                                    WHEN JOB='CLERK' THEN 1000 ELSE 1001 END;
COMMIT;
--
CONNECT Sec_Admin/FhIms9999@IMS;                                  
BEGIN
  SA_COMPONENTS.CREATE_LEVEL(policy_name => 'emp_policy',level_num => 1000,short_name => 'NORMAL',long_name => 'Normal sensitivity');
  SA_COMPONENTS.CREATE_LEVEL(policy_name => 'emp_policy',level_num => 1001,short_name => 'CONFIDENTIAL',long_name => 'high sensitivity');
  SA_COMPONENTS.CREATE_LEVEL(policy_name => 'emp_policy',level_num => 1002,short_name => 'SECRET',long_name => 'very high sensitivity');
END;
/
BEGIN
  SA_LABEL_ADMIN.CREATE_LABEL(policy_name => 'emp_policy',label_tag => 1000,label_value => 'NORMAL',data_label => TRUE);
  SA_LABEL_ADMIN.CREATE_LABEL(policy_name => 'emp_policy',label_tag => 1001,label_value => 'CONFIDENTIAL',data_label => TRUE);
  SA_LABEL_ADMIN.CREATE_LABEL(policy_name => 'emp_policy',label_tag => 1002,label_value => 'SECRET',data_label => TRUE);
END;
/

BEGIN
  SA_POLICY_ADMIN.APPLY_TABLE_POLICY(
    policy_name => 'emp_policy',
    schema_name => 'SCOTT',
    table_name  => 'EMP',
    table_options => 'READ_CONTROL,WRITE_CONTROL'
  );
END;
/

PROMPT Scott may read and write NORMAL and CONFIDENTIAL data, JONES can only read NORMAL data and not write any data
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name    => 'emp_policy',
    user_name      => 'SCOTT',
    max_read_label => 'CONFIDENTIAL',
    min_write_label=> 'NORMAL',
    max_write_label=> 'CONFIDENTIAL',
    def_label      => 'CONFIDENTIAL',
    row_label      => 'CONFIDENTIAL'
  );
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name    => 'emp_policy',
    user_name      => 'JONES',
    max_read_label => 'NORMAL',
    min_write_label=> NULL,
    max_write_label=> NULL,
    def_label      => 'NORMAL',
    row_label      => 'NORMAL'
  );
END;
/

-- check status of created policy
SELECT policy_name,
       status,
       SUBSTR(table_options,1,80) AS Options
FROM   all_sa_table_policies
WHERE  schema_name = 'SCOTT'
AND    table_name   = 'EMP';


PROMPT scott should see all data labelled as NORMAL and CONFIDENTIAL, Jones should only see records marked as "NORMAL"
PROMPT this means, Scott sees 11 instead of 14 records, Jones sees 2 records instead of 4 of his own department

connect scott/tiger@IMS;
SELECT * FROM emp;
--
CONNECT JONES/jones1234@IMS;
SELECT * FROM emp;


--     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO  SEC_LABEL
------------ ---------- --------- ---------- --------- ---------- ---------- ---------- ----------
--      7369 SMITH      CLERK           7902 17-DEC-80        800                    20       1000
--      7499 ALLEN      SALESMAN        7698 20-FEB-81       1600        300         30       1001
--      7521 WARD       SALESMAN        7698 22-FEB-81       1250        500         30       1001
--      7566 JONES      MANAGER         7839 02-APR-81       2975                    20       1001
--      7654 MARTIN     SALESMAN        7698 28-SEP-81       1250       1400         30       1001
--      7698 BLAKE      MANAGER         7839 01-MAY-81       2850                    30       1001
--      7788 SCOTT      ANALYST         7566 19-APR-87       3000                    20       1001
--      7844 TURNER     SALESMAN        7698 08-SEP-81       1500          0         30       1001
--      7876 ADAMS      CLERK           7788 23-MAY-87       1100                    20       1000
--      7900 JAMES      CLERK           7698 03-DEC-81        950                    30       1000
--      7902 FORD       ANALYST         7566 03-DEC-81       3000                    20       1001
--
--11 rows selected.
--
--     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO  SEC_LABEL
------------ ---------- --------- ---------- --------- ---------- ---------- ---------- ----------
--      7369 SMITH      CLERK           7902 17-DEC-80        800                    20       1000
--      7876 ADAMS      CLERK           7788 23-MAY-87       1100                    20       1000
-- 
--2 rows selected.