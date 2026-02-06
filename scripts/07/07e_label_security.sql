-- connect to database as sys user, e.g. docker exec -it -u oracle OracleFree sqlplus 'sys/FhIms9999@IMS as sysdba'
ALTER session SET container=IMS;
select value from v$option where parameter like '%Label%';
-- if this says "FALSE, then run following script
@?/rdbms/admin/catols.sql
-- and the user needs to be unlocked
ALTER USER LBACSYS IDENTIFIED BY FhIms9999 ACCOUNT UNLOCK;
-- even SYS per default is not allowed to create the policies, this only works with separate user inside the PDB
--
ALTER session SET container=IMS;
CREATE USER Sec_Admin IDENTIFIED BY FhIms9999;
GRANT DBA TO Sec_Admin;
GRANT EXECUTE ON SA_SYSDBA TO Sec_Admin;
GRANT EXECUTE ON SA_LABEL_ADMIN TO Sec_Admin;
GRANT EXECUTE ON SA_USER_ADMIN TO Sec_Admin;
GRANT EXECUTE ON SA_POLICY_ADMIN TO Sec_Admin;

GRANT INHERIT PRIVILEGES ON USER LBACSYS TO Sec_Admin;

CONNECT Sec_Admin/FhIms9999@IMS;
-- currently this does not work, but says:
-- ORA-12458: Oracle Label Security is not enabled.
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

ALTER TABLE SCOTT.EMP ADD (SEC_LABEL NUMBER DEFAULT 1001);
UPDATE SCOTT.EMP SET Sec_Label=CASE WHEN DeptNo=10 THEN 1002
                                    WHEN JOB='PRESIDENT' THEN 1002
                                    WHEN JOB='CLERK' THEN 1000 ELSE 1001 END;
COMMIT;
                                    
BEGIN
  SA_LABEL_ADMIN.CREATE_LABEL(
    policy_name  => 'emp_policy',
    label_tag    => 1000,
    label_value  => 'NORMAL',
    data_label   => 'NORMAL'
  );
  
  SA_LABEL_ADMIN.CREATE_LABEL(
    policy_name  => 'emp_policy',
    label_tag    => 1001,
    label_value  => 'CONFIDENTIAL',
    data_label   => 'CONFIDENTIAL'
  );
 
  SA_LABEL_ADMIN.CREATE_LABEL(
    policy_name  => 'emp_policy',
    label_tag    => 1002,
    label_value  => 'SECRET',
    data_label   => 'SECRET'
  );
END;
/

BEGIN
  SA_POLICY_ADMIN.APPLY_TABLE_POLICY(
    policy_name => 'emp_policy',
    schema_name => 'SCOTT',
    table_name  => 'EMP',
    table_options => 'LABEL_DEFAULT'
  );
END;
/

BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name    => 'emp_policy',
    user_name      => 'SCOTT',
    max_read_label => 'CONFIDENTIAL',
    min_read_label => 'NORMAL',
    default_label  => 'CONFIDENTIAL',
    row_label      => 'CONFIDENTIAL'
  );
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name    => 'emp_policy',
    user_name      => 'JONES',
    max_read_label => 'NORMAL',
    min_read_label => 'NORMAL',
    default_label  => 'NORMAL',
    row_label      => 'NORMAL'
  );
END;
/
connect scott/tiger@IMS;
SELECT * FROM emp;
-- scott should see all data labelled as NORMAL and CONFIDENTIAL, Jones should only see records marked as "NORMAL"

 