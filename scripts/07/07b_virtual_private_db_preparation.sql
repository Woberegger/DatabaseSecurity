-- connect to database as sys user, e.g. docker exec -it -u oracle Oracle23Free sqlplus 'sys/FhIms9999 as sysdba'
ALTER session SET container=IMS;
-- create a 2nd DB user, who shall only have limited access to scott's tables (he is a manager and shall see all from his dept)
CREATE USER JONES IDENTIFIED BY jones1234 DEFAULT TABLESPACE DATA TEMPORARY TABLESPACE TEMP;
GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO JONES;
--
-- create a 3rd DB user, who shall only have limited access to scott's tables (he is normal employee and shall only see his own data)
CREATE USER SMITH IDENTIFIED BY smith1234 DEFAULT TABLESPACE DATA TEMPORARY TABLESPACE TEMP;
GRANT CONNECT,RESOURCE TO SMITH;
-- following grant would be necessary, when the policy is installed under user Scott and not under sys
--GRANT EXECUTE ON dbms_rls TO SCOTT;
--GRANT create any context, create public synonym TO SCOTT;

-- connect to scott user and grant some of his objects to Jones (Manager) and Smith (simple clerk)
CONNECT SCOTT/tiger@IMS;
GRANT SELECT ON EMP TO JONES,SMITH;
GRANT SELECT ON DEPT TO JONES,SMITH;
GRANT SELECT ON BONUS TO JONES,SMITH;
GRANT SELECT ON SALGRADE TO JONES,SMITH;
-- and we create a 2nd table, where we store, to which department which employee belongs to
CREATE TABLE EmpRoles (EmpNo, Ename, Job, DeptNo) AS (SELECT EmpNo, Ename, Job, DeptNo FROM Emp);
-- and then create synonyms for Jones/Smith, otherwise he would always have to prefix the table with scott.
CONNECT JONES/jones1234@IMS;
CREATE OR REPLACE SYNONYM EMP FOR SCOTT.EMP;
CREATE OR REPLACE SYNONYM DEPT FOR SCOTT.DEPT;
CREATE OR REPLACE SYNONYM BONUS FOR SCOTT.BONUS;
CREATE OR REPLACE SYNONYM SALGRADE FOR SCOTT.SALGRADE;
--
CONNECT SMITH/smith1234@IMS;
CREATE OR REPLACE SYNONYM EMP FOR SCOTT.EMP;
CREATE OR REPLACE SYNONYM DEPT FOR SCOTT.DEPT;
CREATE OR REPLACE SYNONYM BONUS FOR SCOTT.BONUS;
CREATE OR REPLACE SYNONYM SALGRADE FOR SCOTT.SALGRADE;
--
CONNECT SCOTT/tiger@IMS;
-- this is the policy function. The function itself does not do anything, only when loaded into policy...
-- IMPORTANT: The final / is necessary, it executes the part before as a block, similar to $$ clause in Postgres
CREATE OR REPLACE FUNCTION pf_job (oowner IN VARCHAR2, ojname IN VARCHAR2) RETURN VARCHAR2 AS
  con VARCHAR2 (100); -- condition to return
  vrec_EmpRoles EmpRoles%ROWTYPE;
  v_UserName    EMP.EName%TYPE;
  -- this function shall give full access to scott, managers see all data from their department,
  -- other users only see their own salary
BEGIN
  v_UserName := SYS_CONTEXT('USERENV','SESSION_USER');
  IF (v_UserName = 'SCOTT') THEN
     con := NULL; -- no condition for scott user
  ELSE
     SELECT * INTO vrec_EmpRoles FROM EmpRoles WHERE Ename=v_UserName;
     IF vrec_EmpRoles.Job = 'MANAGER' THEN
        con := 'deptno = '||vrec_EmpRoles.DeptNo;
     ELSE -- take care to specifically quote the string or otherwise use con := 'empno = '||vrec_EmpRoles.EmpNo;
        con := 'ename = '''||v_UserName||'''';
     END IF;
  END IF;
  RETURN (con);
EXCEPTION -- in case of any exception, e.g. user not found in EmpRoles, return a never-matching condition
   WHEN OTHERS THEN 
      con := '0 = 1';
END pf_job;
/
-- continue with 07c_virtual_private_db_policy.sql to create the policy for the above function