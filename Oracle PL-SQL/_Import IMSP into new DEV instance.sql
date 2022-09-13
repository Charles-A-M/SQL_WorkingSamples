/*
Export IPSTST via batch file on wtrOraProd 
expdp \"/ as sysdba\" FULL=y PARALLEL=8 COMPRESSION=ALL DIRECTORY=COD_DUMP_DIR REUSE_DUMPFILES=YES DUMPFILE=<<INSTANCE>>_%u.dmp LOGFILE=<<INSTANCE>>_exp_log.txt filesize=150m


-- Remove old instance from RMAN.
--		unregister database <<instance>>

Delete the old instance
	oradim -delete -sid oldsid
	
Move old FRA and OraData folders to .old to preserve without loss/change. Move to different parent folder so they're not backed up.

Create new DBs using DB configuration tool.
-- ----------------------------------------------
Alter User ION account lock;
Alter User IONWRS account lock;
Alter User SRVCGIS account lock;
Alter User SRVCHANSEN account lock;
Alter User SRVCWATERREVENUE account lock;
-- ----------------------------------------------
Update Keepass if system or sys pwds change.

d:
cd d:\Oracle\Oracle_19.3\OPatch
set oracle_sid=IPSTST 
datapatch -verbose
*/
--Create missing tablespace(s) and make the new import/export dir.
  create smallfile tablespace AUDITTRAILS
    Datafile 'e:\OraData\IPSTST\AuditTrails_01.DBF' SIZE 5m AUTOEXTEND ON NEXT 64m MAXSIZE UNLIMITED 
    BLOCKSIZE 8192 
    DEFAULT COMPRESS 
    ONLINE 
    SEGMENT SPACE MANAGEMENT AUTO 
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
  CREATE SMALLFILE TABLESPACE GRMSTAGING 
    DATAFILE 
        'e:\ORADATA\IPSTST\GRMSTAGING_01.DBF' SIZE  5m AUTOEXTEND ON NEXT 64m MAXSIZE UNLIMITED 
    BLOCKSIZE 8192 
    DEFAULT COMPRESS 
    ONLINE 
    SEGMENT SPACE MANAGEMENT AUTO 
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
  CREATE SMALLFILE TABLESPACE STATSPACK_DATA 
    DATAFILE 
        'e:\ORADATA\IPSTST\StatsPack_01.DBF' SIZE 5m AUTOEXTEND ON NEXT 64m MAXSIZE UNLIMITED 
    BLOCKSIZE 8192 
    DEFAULT COMPRESS 
    ONLINE 
    SEGMENT SPACE MANAGEMENT AUTO 
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
  ALTER TABLESPACE USERS 
	ADD DATAFILE 'e:\ORADATA\IPSTST\USERS_02.DBF' SIZE 3g AUTOEXTEND ON NEXT 160m MAXSIZE 6g;
  ALTER TABLESPACE USERS 
	ADD DATAFILE 'e:\ORADATA\IPSTST\USERS_03.DBF' SIZE 3g AUTOEXTEND ON NEXT 160m MAXSIZE 6g;
  ALTER TABLESPACE USERS 
	ADD DATAFILE 'e:\ORADATA\IPSTST\USERS_04.DBF' SIZE 3g AUTOEXTEND ON NEXT 160m MAXSIZE 6g;
  --ALTER TABLESPACE USERS 
	--ADD DATAFILE 'f:\ORADATA\IPSTST\USERS_05.DBF' SIZE 3g AUTOEXTEND ON NEXT 160m MAXSIZE 4g;
  ALTER DATABASE 
	DATAFILE 'e:\ORADATA\IPSTST\USERS01.DBF' RESIZE 3g ;
  ALTER DATABASE 
	DATAFILE 'e:\ORADATA\IPSTST\USERS01.DBF' AUTOEXTEND ON NEXT 160m MAXSIZE 6g;
  CREATE SMALLFILE TABLESPACE USERINDEXES 
    DATAFILE 
        'e:\ORADATA\IPSTST\USERINDEXES_01.DBF' SIZE 3g AUTOEXTEND ON NEXT 160m MAXSIZE UNLIMITED ,
        'e:\ORADATA\IPSTST\USERINDEXES_02.DBF' SIZE 3g AUTOEXTEND ON NEXT 160m MAXSIZE UNLIMITED ,
        'e:\ORADATA\IPSTST\USERINDEXES_03.DBF' SIZE 3g AUTOEXTEND ON NEXT 160m MAXSIZE UNLIMITED 
    BLOCKSIZE 8192 
    DEFAULT COMPRESS NO INMEMORY 
    ONLINE 
    SEGMENT SPACE MANAGEMENT AUTO 
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;	
  ALTER DATABASE SET TIME_ZONE = 'US/Eastern' ;
  
  alter profile DEFAULT limit PASSWORD_REUSE_TIME unlimited;
  alter profile DEFAULT limit PASSWORD_LIFE_TIME  unlimited;
  
  EXEC dbms_stats.init_package();
  
  -- Not doing this can block exports for some reason? :
  alter system set db_securefile=PERMITTED sid='*' scope = both;
  CREATE or REPLACE DIRECTORY cod_dump_dir as 'F:\Exports\IPSTST'; 
  grant READ, WRITE on directory cod_dump_dir to public ;

  ALTER SYSTEM SET smtp_out_server='smtp.daytonohio.gov' SCOPE=both;
 
	commit;
EXIT
-- ----------------------------------------------
--
-- Import Production Data.

  
  /*
set Oracle_SID=IPSTST0x
exclude Oracle-provided schemas:
impdp \"/ as sysdba\" dumpfile=IpsProd_%u.DMP directory=COD_DUMP_DIR PARFILE=f:\Exports\exclude.par LOGFILE=IPSTST_imp_log.txt TABLE_EXISTS_ACTION=REPLACE



-- generate SQL DDL syntax from the full backup:
impdp \"/ as sysdba\" dumpfile=IpsProd_%u.DMP directory=COD_DUMP_DIR PARFILE=f:\Exports\exclude.par sqlfile=Full_DDL.sql LOGFILE=Full_DDL.txt

-- impdp \"/  as sysdba\" FULL=y DUMPFILE=IMSP_exp_%u.dmp DIRECTORY=COD_DUMP_DIR TABLE_EXISTS_ACTION=REPLACE LOGFILE=IPSTST_imp_log.txt
-- impdp \"/  as sysdba\" FULL=y DUMPFILE=IMSP_exp_%u.dmp DIRECTORY=COD_DUMP_DIR TABLE_EXISTS_ACTION=Skip LOGFILE=IPSTST_imp_log.txt

 -- keep dbms_clrdblink :
Select 'Drop Public Database Link ' || db_link || '; ' a from dba_db_links where Owner = 'PUBLIC' and db_link not like '%CLRDB%';
--
 

 wtrCrystal
 wtrCrystal-dev
 wtrcrystaldev
 
-- ----------------------------------------------
Alter User CRYSTAL account unlock;
Alter User ION account unlock;
Alter User IONWRS account unlock;
Alter User SRVCGIS account unlock;
Alter User SRVCHANSEN account unlock;
Alter User SRVCSOLARWINDS account unlock;
Alter User SRVCWATERREVENUE account unlock;
 
-- ----------------------------------------------
--
*/

	@D:\Oracle\Oracle_19.3\rdbms\admin\utlmail.sql;
	@D:\Oracle\Oracle_19.3\rdbms\admin\prvtmail.plb;
	grant execute on utl_mail to system;
	grant execute on utl_mail to srvcinfor;
	grant execute on utl_mail to oldsystem;
	--- creating ACL as below
	exec DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('send_mail.xml','Allow mail to be send', 'OLDSYSTEM', TRUE, 'connect');
	commit;
	-- Grant the connect and resource privilege as below
	exec DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE('send_mail.xml','OLDSYSTEM', TRUE, 'connect');
	exec DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE('send_mail.xml','OLDSYSTEM', TRUE, 'resolve');
	exec DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('send_mail.xml','*',25);
	commit;
	
--OLDSYSTEM Schema!
-- Table Synonyms
CREATE OR REPLACE SYNONYM "SYSTEM"."INTERFACELOG" FOR "OLDSYSTEM"."INTERFACELOG";
CREATE OR REPLACE SYNONYM "SYSTEM"."PRTSTK" FOR "OLDSYSTEM"."PRTSTK";
CREATE OR REPLACE SYNONYM "SYSTEM"."SEQUENCEFIXLOG" FOR "OLDSYSTEM"."SEQUENCEFIXLOG";
CREATE OR REPLACE SYNONYM "SYSTEM"."SOLIDWASTESRC" FOR "OLDSYSTEM"."SOLIDWASTESRC";
--
--Packages
CREATE OR REPLACE SYNONYM "SYSTEM"."PROPERTY" FOR "OLDSYSTEM"."PROPERTY";
--
-- procedures
CREATE OR REPLACE SYNONYM "SYSTEM"."ADDRPARSE" FOR "OLDSYSTEM"."ADDRPARSE";
CREATE OR REPLACE SYNONYM "SYSTEM"."FIXDUPADDR" FOR "OLDSYSTEM"."FIXDUPADDR";
CREATE OR REPLACE SYNONYM "SYSTEM"."INSERT_INTO_INTERFACE_LOG" FOR "OLDSYSTEM"."INSERT_INTO_INTERFACE_LOG";
CREATE OR REPLACE SYNONYM "SYSTEM"."SOLIDWASTECONVERSION" FOR "OLDSYSTEM"."SOLIDWASTECONVERSION";
CREATE OR REPLACE SYNONYM "SYSTEM"."STKLOC" FOR "OLDSYSTEM"."STKLOC";
CREATE OR REPLACE SYNONYM "SYSTEM"."WC_CONT_LOAD" FOR "OLDSYSTEM"."WC_CONT_LOAD";
--
--Functions
CREATE OR REPLACE SYNONYM "SYSTEM"."BLOB_TO_XMLTYPE" FOR "OLDSYSTEM"."BLOB_TO_XMLTYPE";
CREATE OR REPLACE SYNONYM "SYSTEM"."SR_COMMENTS" FOR "OLDSYSTEM"."SR_COMMENTS";
CREATE OR REPLACE SYNONYM "SYSTEM"."SRCOMMENTS" FOR "OLDSYSTEM"."SRCOMMENTS";  
CREATE OR REPLACE SYNONYM "SYSTEM"."STRING_AGG" FOR "OLDSYSTEM"."STRING_AGG";
--
--Types
CREATE OR REPLACE SYNONYM "SYSTEM"."T_String_Agg" FOR "OLDSYSTEM"."T_String_Agg";
--
-- ---------------------------------------------------------
--ION Schema!
--Tables
CREATE OR REPLACE SYNONYM "SYSTEM"."COR_INBOX_ENTRY" FOR "ION"."COR_INBOX_ENTRY";
CREATE OR REPLACE SYNONYM "SYSTEM"."COR_INBOX_HEADERS" FOR "ION"."COR_INBOX_HEADERS";
CREATE OR REPLACE SYNONYM "SYSTEM"."COR_OUTBOX_ENTRY" FOR "ION"."COR_OUTBOX_ENTRY";
CREATE OR REPLACE SYNONYM "SYSTEM"."COR_OUTBOX_HEADERS" FOR "ION"."COR_OUTBOX_HEADERS";
CREATE OR REPLACE SYNONYM "SYSTEM"."COR_PROPERTY" FOR "ION"."COR_PROPERTY";
CREATE OR REPLACE SYNONYM "SYSTEM"."ESB_INBOUND_DUPLICATE" FOR "ION"."ESB_INBOUND_DUPLICATE";
--
--Sequences
CREATE OR REPLACE SYNONYM "SYSTEM"."ZEQ_COR_INBOX_ENTRY" FOR "ION"."COR_INBOX_ENTRY_SEQ";
CREATE OR REPLACE SYNONYM "SYSTEM"."ZEQ_COR_INBOX_HEADERS" FOR "ION"."COR_INBOX_HEADERS_SEQ";
CREATE OR REPLACE SYNONYM "SYSTEM"."ZEQ_COR_OUTBOX_ENTRY" FOR "ION"."COR_OUTBOX_ENTRY_SEQ";
CREATE OR REPLACE SYNONYM "SYSTEM"."ZEQ_COR_OUTBOX_HEADERS" FOR "ION"."COR_OUTBOX_HEADERS_SEQ";
commit;

/*
-- ----------------------------------------------
--
--  C:\Users\charles.moore\OneDrive - City of Dayton\Oracle\Oracle SQL\Audit\Enable Auditing.sql
--


	
--Add new instance to RMAN.
set Oracle_SID=IPSTST
rman target / catalog=rcat_user/codWaterBackups@mgmt

upgrade catalog;
Register database;

 for rman on 12.1 on WtrOracle : 	C:\Oracle\product\12.1.0\dbhome_1\BIN

	--  if a newer version or patch set.
	
	#-- Note the NEW SID!  	
 
	CONFIGURE CONTROLFILE AUTOBACKUP Off;
	CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 14 DAYS;
	# for load true means no precompression block processing. with PBP, higher CPU usage.
	configure compression algorithm 'MEDIUM' optimize for load false;
	configure device type disk backup type to compressed backupset;
	configure device type disk parallelism 4;   

	backup device type disk incremental level = 0 section size 1g database plus archivelog tag 'level 0';
	backup current controlfile tag='Controlfile Level 0';
	backup spfile tag='sPFile Level 0';

	allocate channel for maintenance type disk;
	backup validate check logical database archivelog all;

	crosscheck archivelog all;
	crosscheck backupset ;
	crosscheck backup device type disk;
	release channel;
	Exit;


update rcat_user.Cod_DBLookup set db_Decom = sysdate where db_id in (3438868141);
insert into cod_DBLookup (db_id, db_name, db_Server, db_version, isProd) values (3450347174, 'IPSTST', 'WtrOracle', '12.2', 'N');
commit;
Select * 
  from rcat_user.cod_dblookup
 --where db_name like 'IPSD%'
 order by DB_SERVER, DB_NAME;
	  
	  
--Shut down the new database and restart. Make sure you can log in. Fix any file permissions issues that come up.
--Notify users.
     
Update TNSNAMES files if needed.
update the spreadsheet \\IT-MOOREC1-LT\Dropbox$\CoD Db Servers.xlsm.
update the monitoring database with new passwords (if needed).
update the export scripts to use the correct paths.

--IMSP required by Crystal:
--ALTER SYSTEM SET SEC_CASE_SENSITIVE_LOGON = FALSE scope=both;

--and this in SQLNET.ORA:
--#for Crystal Reports.
--SQLNET.ALLOWED_LOGON_VERSION_SERVER=8



Oracle migration playbook:
Lock SRVHANSEN and ION accounts to block access.
Start IMSP export. 3.5 hours. While that runs, 
	drop and recreate IPSTST instance.
	Perform tablespace script steps above.
	register db with RMAN.
After export:
Start import. while that runs, 
	perform full backup of IMSP
	shut down IMSP
Unlock srvhansen and ion accounts.
Notify Nick to update Hansen connect strings
end of outage.
Begin full backup.
Begin export.	


Alter User IONWRS account lock;
Alter User ION account lock;
Alter User SRVCWATERREVENUE account lock;
Alter User SRVCSOLARWINDS account lock;
Alter User CRYSTAL account lock;
Alter User SRVCGIS account lock;
Alter User BACKUPUSER account lock;
Alter User SRVCHANSEN account lock;

select username, last_login,  created,
    'Alter User ' || username || ' account lock;' LockUser
from dba_users
where oracle_maintained = 'N'
  and account_status='OPEN'
  and last_login is not null
order by 2;
 
*/