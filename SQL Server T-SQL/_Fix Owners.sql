--  https://www.brentozar.com/blitz/jobs-owned-by-user-accounts/


select
(case when D.is_read_only = 1 then '-- Remove ReadOnly State' when D.state_desc = 'ONLINE' then 'ALTER AUTHORIZATION on DATABASE::['+D.name+'] to [SA];' else '-- Turn On ' end) as CommandToRun
,D.name as Database_Name
, D.database_id as Database_ID
,L.Name as Login_Name
,D.state_desc as Current_State
,D.is_read_only as [ReadOnly]
from master.sys.databases D
inner join master.sys.syslogins L on D.owner_sid = L.sid
where L.Name <> 'sa'
order by D.Name;
 
--Agent Jobs
 
 
--Agent Jobs
select
J.name as SQL_Agent_Job_Name
,msdb.dbo.SQLAGENT_SUSER_SNAME(j.owner_sid) as Job_Owner
,J.description
,C.name
,'EXEC msdb.dbo.sp_update_job @job_id=N'''+cast(job_id as varchar(150))+''', @owner_login_name=N''sa'' ' as RunCode
from msdb.dbo.sysjobs j
--inner join master.sys.syslogins L on J.owner_sid = L.sid
inner join msdb.dbo.syscategories C on C.category_id = J.category_id
where msdb.dbo.SQLAGENT_SUSER_SNAME(j.owner_sid) <> 'sa';


--HADR (AG) End points
--   https://www.mssqltips.com/sqlservertip/5201/drop-login-issues-for-logins-tied-to-sql-server-availability-groups/

  SELECT pm.class, pm.class_desc, pm.major_id, pm.minor_id, 
   pm.grantee_principal_id, pm.grantor_principal_id, 
   pm.[type], pm.[permission_name], pm.[state],pm.state_desc, 
   pr.[name] AS [owner], gr.[name] AS grantee, e.[name] AS endpoint_name,
   'ALTER AUTHORIZATION ON ENDPOINT::' + e.[name] + ' TO sa;' [Sql]
FROM sys.server_permissions pm 
   JOIN sys.server_principals pr ON pm.grantor_principal_id = pr.principal_id
   JOIN sys.server_principals gr ON pm.grantee_principal_id = gr.principal_id
   JOIN sys.endpoints e ON pm.grantor_principal_id = e.principal_id 
        AND pm.major_id = e.endpoint_id
where pr.[name] <> 'sa';

