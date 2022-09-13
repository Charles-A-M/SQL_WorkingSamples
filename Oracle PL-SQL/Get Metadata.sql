/* ============================================================================
select distinct instance from alltables
oP	IMSP			Ora	PRODUCTION DATA
oX	IPSDevX			Ora	Nick's sandbox
oT	IPSTest			Ora	Testing upgrades
sM	IPS_SSMAtest	SQL	A clone of IPS_Baseline, with migrated copy IMSP’s data into those tables. No custom objects migrated. Previous Version.
SN	IPS_SSMAtestB	SQL	migration of IMSP data AND schema. The table definitions are wrong (wrong data types for some columns) Previous Version.
sB	IPS_Baseline	SQL	Hansen install on SQL with no data migration, just Hansen’s default data values. Version?
*/
-- ============================================================================
-- ============================================================================
--
--									Users
--
-- ============================================================================
;with oP as (
	select id, instance, UserName, Oracle_Maintained, Account_Status from allUsers where Instance = 'IMSP'
), oX as (
	select id, instance, UserName, Oracle_Maintained, Account_Status from allUsers where Instance = 'IPSDevX'
), oT as (
	select id, instance, UserName, Oracle_Maintained, Account_Status from allUsers where Instance = 'IPSTest'
), sM as (
	select id, instance, UserName, Oracle_Maintained, Account_Status from allUsers where Instance = 'IPS_SSMAtest'
), sN as (
	select id, instance, UserName, Oracle_Maintained, Account_Status from allUsers where Instance = 'IPS_SSMAtestB'
), sB as (
	select id, instance, UserName, Oracle_Maintained, Account_Status from allUsers where Instance = 'IPS_Baseline'
), v as (
	select distinct UserName, Oracle_Maintained from allUsers 
)
select distinct UserName   [Schema Name]
	, ( select count(*) from oP where op.UserName = v.UserName ) IMSP
	, ( select count(*) from oX where ox.UserName = v.UserName ) IPSDevX
	, ( select count(*) from oT where oT.UserName = v.UserName ) IPSTest
	, ( select count(*) from sB where sb.UserName = v.UserName ) IPS_Baseline
	, ( select count(*) from sM where sm.UserName = v.UserName ) IPS_Data
	, ( select count(*) from sN where sn.UserName = v.UserName ) IPS_DataSchema
 from v
 order by 1
-- ============================================================================
--
--									Tables
--
-- ============================================================================
;with oP as (
	select id, instance, [Owner] [Schema], Table_Name from AllTables where Instance = 'IMSP'
), oX as (
	select id, instance, [Owner] [Schema], Table_Name from AllTables where Instance = 'IPSDevX'
), oT as (
	select id, instance, [Owner] [Schema], Table_Name from AllTables where Instance = 'IPSTest'
), sM as (
	select id, instance, [Owner] [Schema], Table_Name from AllTables where Instance = 'IPS_SSMAtest'
), sN as (
	select id, instance, [Owner] [Schema], Table_Name from AllTables where Instance = 'IPS_SSMAtestB'
), sB as (
	select id, instance, [Owner] [Schema], Table_Name from AllTables where Instance = 'IPS_Baseline'
), v as (
	select distinct [Owner] [Schema], Table_Name  from AllTables 
)
select distinct [Schema], Table_Name [Table Name]
	, ( select count(*) from oP where op.[Schema] = v.[Schema] and op.Table_Name = v.Table_Name ) IMSP
	, ( select count(*) from oX where ox.[Schema] = v.[Schema] and ox.Table_Name = v.Table_Name ) IPSDevX
	, ( select count(*) from oT where oT.[Schema] = v.[Schema] and ot.Table_Name = v.Table_Name ) IPSTest
	, ( select count(*) from sB where sb.[Schema] = v.[Schema] and sb.Table_Name = v.Table_Name ) IPS_Baseline
	, ( select count(*) from sM where sm.[Schema] = v.[Schema] and sm.Table_Name = v.Table_Name ) IPS_Data
	, ( select count(*) from sN where sn.[Schema] = v.[Schema] and sn.Table_Name = v.Table_Name ) IPS_DataSchema
 from v
 order by 1, 2
-- ============================================================================
--
--									VIEWS
--
-- ============================================================================
;with oP as (
	select id, instance, owner, view_name, text_length, text_vc from allViews where Instance = 'IMSP'
), oX as (
	select id, instance, owner, view_name, text_length, text_vc from allViews where Instance = 'IPSDevX'
), oT as (
	select id, instance, owner, view_name, text_length, text_vc from allViews where Instance = 'IPSTest'
), sM as (
	select id, instance, owner, view_name, text_length, text_vc from allViews where Instance = 'IPS_SSMAtest'
), sN as (
	select id, instance, owner, view_name, text_length, text_vc from allViews where Instance = 'IPS_SSMAtestB'
), sB as (
	select id, instance, owner, view_name, text_length, text_vc from allViews where Instance = 'IPS_Baseline'
), v as (
	select distinct [Owner], View_Name from allViews 
)
select [Owner], View_Name
	, ( select count(*) from oP where op.view_name = v.view_name and op.[Owner] = v.[Owner] ) IMSP
	, ( select count(*) from oX where ox.view_name = v.view_name and ox.[Owner] = v.[Owner] ) IPSDevX
	, ( select count(*) from oT where oT.view_name = v.view_name and ot.[Owner] = v.[Owner] ) IPSTest
	, ( select count(*) from sB where sb.view_name = v.view_name and sb.[Owner] = v.[Owner] ) IPS_Baseline
	, ( select count(*) from sM where sm.view_name = v.view_name and sm.[Owner] = v.[Owner] ) IPS_Data
	, ( select count(*) from sN where sn.view_name = v.view_name and sn.[Owner] = v.[Owner] ) IPS_DataSchema
 from v
 order by 1, 2
-- ============================================================================
--
--									Table Columns
--
-- ============================================================================
 ;with oP as (
	select owner, table_name, column_id, column_name,
	case 
		when data_type = 'bigint' then 'Number (19)'
		when data_type = 'int' then 'Number (10)'
		when data_type = 'smallint' then 'Number (6)'
		when data_type = 'CHAR' then 'Char('+ cast(data_length as varchar) + ')'
		when data_type = 'DATE' or data_type = 'datetime' then 'DateTime'
		when data_type in( 'decimal', 'money', 'NUMBER', 'numeric')
			then 'Number' + isnull('(' + cast(data_precision as varchar) + ',' + cast(data_scale as varchar) + ')', '')
		
		when data_type = 'NVARCHAR2' or data_type = 'nvarchar' then 'NVarChar(' + cast(data_length as varchar) + ')'
		when data_type = 'VARCHAR2' or data_type = 'varchar' then 'VarChar(' + cast(data_length as varchar) + ')'
		else data_type end --bit, BLOB, CLOB, datetime2, datetimeoffset ,FLOAT, geometry, RAW, ROWID
		+ case when nullable = 'Y' or nullable = '1' then ' NULL' else ' NOT NULL' end [Data Definition]
	from allTableCols
	where  instance='IMSP'
), oX as (
	select owner, table_name, column_id, column_name,
	case 
		when data_type = 'bigint' then 'Number (19)'
		when data_type = 'int' then 'Number (10)'
		when data_type = 'smallint' then 'Number (6)'
		when data_type = 'CHAR' then 'Char('+ cast(data_length as varchar) + ')'
		when data_type = 'DATE' or data_type = 'datetime' then 'DateTime'
		when data_type in( 'decimal', 'money', 'NUMBER', 'numeric')
			then 'Number' + isnull('(' + cast(data_precision as varchar) + ',' + cast(data_scale as varchar) + ')', '')
		
		when data_type = 'NVARCHAR2' or data_type = 'nvarchar' then 'NVarChar(' + cast(data_length as varchar) + ')'
		when data_type = 'VARCHAR2' or data_type = 'varchar' then 'VarChar(' + cast(data_length as varchar) + ')'
		else data_type end --bit, BLOB, CLOB, datetime2, datetimeoffset ,FLOAT, geometry, RAW, ROWID
		+ case when nullable = 'Y' or nullable = '1' then ' NULL' else ' NOT NULL' end [Data Definition]
	from allTableCols
	where  instance='IPSDevX'
), oT as (
	select owner, table_name, column_id, column_name,
	case 
		when data_type = 'bigint' then 'Number (19)'
		when data_type = 'int' then 'Number (10)'
		when data_type = 'smallint' then 'Number (6)'
		when data_type = 'CHAR' then 'Char('+ cast(data_length as varchar) + ')'
		when data_type = 'DATE' or data_type = 'datetime' then 'DateTime'
		when data_type in( 'decimal', 'money', 'NUMBER', 'numeric')
			then 'Number' + isnull('(' + cast(data_precision as varchar) + ',' + cast(data_scale as varchar) + ')', '')
		
		when data_type = 'NVARCHAR2' or data_type = 'nvarchar' then 'NVarChar(' + cast(data_length as varchar) + ')'
		when data_type = 'VARCHAR2' or data_type = 'varchar' then 'VarChar(' + cast(data_length as varchar) + ')'
		else data_type end --bit, BLOB, CLOB, datetime2, datetimeoffset ,FLOAT, geometry, RAW, ROWID
		+ case when nullable = 'Y' or nullable = '1' then ' NULL' else ' NOT NULL' end [Data Definition]
	from allTableCols
	where  instance='IPSTest'
), sM as (
	select owner, table_name, column_id, column_name,
	case 
		when data_type = 'bigint' then 'Number (19)'
		when data_type = 'int' then 'Number (10)'
		when data_type = 'smallint' then 'Number (6)'
		when data_type = 'CHAR' then 'Char('+ cast(data_length as varchar) + ')'
		when data_type = 'DATE' or data_type = 'datetime' then 'DateTime'
		when data_type in( 'decimal', 'money', 'NUMBER', 'numeric')
			then 'Number' + isnull('(' + cast(data_precision as varchar) + ',' + cast(data_scale as varchar) + ')', '')
		
		when data_type = 'NVARCHAR2' or data_type = 'nvarchar' then 'NVarChar(' + cast(data_length as varchar) + ')'
		when data_type = 'VARCHAR2' or data_type = 'varchar' then 'VarChar(' + cast(data_length as varchar) + ')'
		else data_type end --bit, BLOB, CLOB, datetime2, datetimeoffset ,FLOAT, geometry, RAW, ROWID
		+ case when nullable = 'Y' or nullable = '1' then ' NULL' else ' NOT NULL' end [Data Definition]
	from allTableCols
	where  instance='IPS_SSMAtest'
), sN as (
	select owner, table_name, column_id, column_name,
	case 
		when data_type = 'bigint' then 'Number (19)'
		when data_type = 'int' then 'Number (10)'
		when data_type = 'smallint' then 'Number (6)'
		when data_type = 'CHAR' then 'Char('+ cast(data_length as varchar) + ')'
		when data_type = 'DATE' or data_type = 'datetime' then 'DateTime'
		when data_type in( 'decimal', 'money', 'NUMBER', 'numeric')
			then 'Number' + isnull('(' + cast(data_precision as varchar) + ',' + cast(data_scale as varchar) + ')', '')
		
		when data_type = 'NVARCHAR2' or data_type = 'nvarchar' then 'NVarChar(' + cast(data_length as varchar) + ')'
		when data_type = 'VARCHAR2' or data_type = 'varchar' then 'VarChar(' + cast(data_length as varchar) + ')'
		else data_type end --bit, BLOB, CLOB, datetime2, datetimeoffset ,FLOAT, geometry, RAW, ROWID
		+ case when nullable = 'Y' or nullable = '1' then ' NULL' else ' NOT NULL' end [Data Definition]
	from allTableCols
	where  instance='IPS_SSMAtest'
), sB as (
	select owner, table_name, column_id, column_name,
	case 
		when data_type = 'bigint' then 'Number (19)'
		when data_type = 'int' then 'Number (10)'
		when data_type = 'smallint' then 'Number (6)'
		when data_type = 'CHAR' then 'Char('+ cast(data_length as varchar) + ')'
		when data_type = 'DATE' or data_type = 'datetime' then 'DateTime'
		when data_type in( 'decimal', 'money', 'NUMBER', 'numeric')
			then 'Number' + isnull('(' + cast(data_precision as varchar) + ',' + cast(data_scale as varchar) + ')', '')
		
		when data_type = 'NVARCHAR2' or data_type = 'nvarchar' then 'NVarChar(' + cast(data_length as varchar) + ')'
		when data_type = 'VARCHAR2' or data_type = 'varchar' then 'VarChar(' + cast(data_length as varchar) + ')'
		else data_type end --bit, BLOB, CLOB, datetime2, datetimeoffset ,FLOAT, geometry, RAW, ROWID
		+ case when nullable = 'Y' or nullable = '1' then ' NULL' else ' NOT NULL' end [Data Definition]
	from allTableCols
	where  instance='IPS_Baseline'
), v as (
select  owner, table_name, column_name, count(*) cnt
	from allTableCols
	group by owner, table_name, column_name
	having count(*) <> 6
)
select v.owner, v.table_name, v.column_name, cnt
	, isnull(op.[Data Definition], '-') IMSP
	, isnull(ox.[Data Definition], '-') IPSDevX
	, isnull(ot.[Data Definition], '-') IPSTest
	, isnull(sb.[Data Definition], '-') IPS_Baseline
	, isnull(sm.[Data Definition], '-') IPS_Data
	, isnull(sn.[Data Definition], '-') IPS_DataSchema
  from v
  left join oP on op.Owner = v.Owner and op.Table_Name = v.Table_Name and op.column_name = v.column_name
  left join oX on op.Owner = v.Owner and ox.Table_Name = v.Table_Name and ox.column_name = v.column_name
  left join oT on op.Owner = v.Owner and ot.Table_Name = v.Table_Name and ot.column_name = v.column_name
  left join sM on op.Owner = v.Owner and sm.Table_Name = v.Table_Name and sm.column_name = v.column_name
  left join sN on op.Owner = v.Owner and sn.Table_Name = v.Table_Name and sn.column_name = v.column_name
  left join sB on op.Owner = v.Owner and sb.Table_Name = v.Table_Name and sb.column_name = v.column_name
  order by 1, 2, 3