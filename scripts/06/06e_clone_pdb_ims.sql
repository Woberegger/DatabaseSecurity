-- connect to database as sys user, e.g. docker exec -it -u oracle Oracle23Free sqlplus '/ as sysdba'
-- important: this only works, when you are connected to the CDB and not to other PDB -- should show CDB
ALTER SESSION SET CONTAINER=cdb$root;
SHOW CON_NAME;
CREATE Pluggable Database IMS_COPY FROM IMS FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE/IMS/','/opt/oracle/oradata/FREE/IMS_COPY/');
-- open the newly created DB
ALTER Pluggable Database IMS_COPY OPEN;
-- change to the container to see, if it works
ALTER session SET container=IMS_COPY;
SELECT UserName FROM ALL_USERS WHERE UserName IN ('SCOTT','IMS');
-- should find the new files
SELECT FILE_NAME FROM dba_data_files;
--
ALTER SESSION SET CONTAINER=cdb$root;
ALTER PLUGGABLE DATABASE IMS_COPY CLOSE;
DROP PLUGGABLE DATABASE IMS_COPY INCLUDING DATAFILES;
-- we expect, that this directory is empty now, as the datafiles were deleted as well
host ls /opt/oracle/oradata/FREE/IMS_COPY/