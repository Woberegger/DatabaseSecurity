ALTER session SET container=IMS;
CREATE USER JONES IDENTIFIED BY jones1234 DEFAULT TABLESPACE DATA TEMPORARY TABLESPACE TEMP;
GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO JONES;
GRANT EXECUTE ON dbms_rls TO JONES;
GRANT EXECUTE ON dbms_rls TO SCOTT;
GRANT create any context, create public synonym TO JONES;

--
CONNECT SCOTT/tiger@IMS;
GRANT ALL ON EMP TO JONES;
GRANT ALL ON DEPT TO JONES;
GRANT ALL ON BONUS TO JONES;
GRANT ALL ON SALGRADE TO JONES;
--
CONNECT JONES/jones1234@IMS;
CREATE OR REPLACE SYNONYM EMP FOR SCOTT.EMP;
CREATE OR REPLACE SYNONYM DEPT FOR SCOTT.DEPT;
CREATE OR REPLACE SYNONYM BONUS FOR SCOTT.BONUS;
CREATE OR REPLACE SYNONYM SALGRADE FOR SCOTT.SALGRADE;
--
CREATE OR REPLACE FUNCTION pf_job (oowner IN VARCHAR2, ojname IN VARCHAR2) RETURN VARCHAR2 AS
  con VARCHAR2 (100); -- condition to return
BEGIN
  IF (SYS_CONTEXT('USERENV','SESSION_USER') = 'SCOTT') THEN
     con := NULL; -- no condition for scott user
  ELSE 
     con := 'deptno = 20'; -- here hard-coded condition, better would be to have a separate table, which is not restricted by policy to find out the according dept
     -- the following recursion also does not work...
     --con := 'deptno = (SELECT MAX(DeptNo) FROM Emp WHERE Ename=SYS_CONTEXT(''USERENV'',''SESSION_USER''))';
  END IF;
  RETURN (con);
END pf_job;
/
