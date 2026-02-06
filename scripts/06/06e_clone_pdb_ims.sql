-- connect to database as sys user, e.g. docker exec -it -u oracle OracleFree sqlplus '/ as sysdba'
-- e.g. docker cp ~/DatabaseSecurity/scripts/06/06e_clone_pdb_ims.sql OracleFree:/tmp/
-- time docker exec -it -u oracle OracleFree sqlplus / as sysdba @/tmp/06e_clone_pdb_ims.sql
PROMPT IMPORTANT: this only works, when you are connected to the CDB and not to other PDB
ALTER SESSION SET CONTAINER=cdb$root;
SHOW CON_NAME;
PROMPT creating pluggable DB IMS_COPY from IMS ...
CREATE Pluggable Database IMS_COPY FROM IMS FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE/IMS/','/opt/oracle/oradata/FREE/IMS_COPY/');

PROMPT opening the newly created DB ...
ALTER Pluggable Database IMS_COPY OPEN;

PROMPT change to the container to see, if it works ...
ALTER session SET container=IMS_COPY;
PROMPT check, if users SCOTT and IMS are existing in clone, too ...
SELECT UserName FROM ALL_USERS WHERE UserName IN ('SCOTT','IMS');
PROMPT should find the new datafiles including tablespaces data+indexes, which were added in IMS
SELECT FILE_NAME FROM dba_data_files;
PROMPT leave container and go back to CDB ...
ALTER SESSION SET CONTAINER=cdb$root;
PROMPT close the pluggable DB ...
ALTER PLUGGABLE DATABASE IMS_COPY CLOSE;
PROMPT drop the pluggable DB including datafiles
DROP PLUGGABLE DATABASE IMS_COPY INCLUDING DATAFILES;
PROMPT we expect, that this directory is empty now, as the datafiles were deleted as well ...
host ls /opt/oracle/oradata/FREE/IMS_COPY/
quit