-- connect to database as sys user, e.g. docker exec -it -u oracle Oracle23Free sqlplus 'sys/FhIms9999@IMS as sysdba'
ALTER session SET container=IMS;

/* the following is not necessary, it shall only demonstrate, how a specific context upon login can be set, which could later be evaluated in the policy
   (using named context "EMPCTX" and writing a logon trigger)
-- specific policies
CREATE OR REPLACE PACKAGE context_package AS
  PROCEDURE set_context;
END;
/

CREATE OR REPLACE PACKAGE BODY context_package IS
  PROCEDURE set_context IS
    v_ouser  VARCHAR2(30);
    v_id     NUMBER;
  BEGIN
    DBMS_SESSION.set_context('EMPCTX','SETUP','TRUE');
    v_ouser := SYS_CONTEXT('USERENV','SESSION_USER');
    
    BEGIN
      -- if we do  not find the user, then return -1 as DeptNo
      SELECT NVL(MAX(deptno),-1)
      INTO   v_id
      FROM   scott.emp
      WHERE  ename = v_ouser;
      
      DBMS_SESSION.set_context('EMPCTX','DEPT_ID', v_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_SESSION.set_context('EMPCTX','DEPT_ID', 0);
    END;
    
    DBMS_SESSION.set_context('EMPCTX','SETUP','FALSE');
  END set_context;
END context_package;
/

GRANT EXECUTE ON context_package TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM context_package FOR context_package;

--
CREATE OR REPLACE TRIGGER set_security_context
AFTER LOGON ON DATABASE
BEGIN
  context_package.set_context;
END;
/

CREATE OR REPLACE CONTEXT EMPCTX USING context_package;
*/
connect sys/FhIms9999@IMS as sysdba
--
BEGIN
  -- activate the lines, when the policy was already existing before
  DBMS_RLS.DROP_POLICY(object_schema     => 'SCOTT',
                       object_name       => 'EMP',
                       policy_name       => 'sp_job');
  DBMS_RLS.ADD_POLICY (object_schema     => 'SCOTT',
                       object_name       => 'EMP',
                       policy_name       => 'sp_job',
                       function_schema   => 'SCOTT',
                       policy_function   => 'pf_job',
                       sec_relevant_cols => 'SAL,COMM');
END;
/

CONNECT JONES/jones1234@IMS;
set lines 300 pages 300;
select * from emp ORDER BY EmpNO ASC;

-- expected output is the following (only 5 records instead of 14)
--     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO
------------ ---------- --------- ---------- --------- ---------- ---------- ----------
--      7369 SMITH      CLERK           7902 17-DEC-80        800                    20
--      7566 JONES      MANAGER         7839 02-APR-81       2975                    20
--      7788 SCOTT      ANALYST         7566 19-APR-87       3000                    20
--      7876 ADAMS      CLERK           7788 23-MAY-87       1100                    20
--      7902 FORD       ANALYST         7566 03-DEC-81       3000                    20

CONNECT smith/smith1234@IMS;
set lines 300 pages 300;
-- however scott sees all data
select * from emp ORDER BY EmpNO ASC;

CONNECT scott/tiger@IMS;
set lines 300 pages 300;
-- however scott sees all data
select * from emp ORDER BY EmpNO ASC;


