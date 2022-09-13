--all errors:
select * 
  from ExtendedEvents 
where ErrorNumber is not null
  and datediff(HOUR, Corrected_Time, SYSDATETIME()) < 24
order by Corrected_Time desc, server_instance_name;



select server_instance_name [DB Server], 
	database_name [Database], 
	client_hostname [Client], 
	case when client_app_name like 'ArcGIS:%' then 'ArcGIS'
		when client_app_name like 'SDE:%' then 'SDE'
		when client_app_name like 'Microsoft SQL Server Management%' then 'MS SSMS'
		else client_app_name end [Client App],
	coalesce(session_nt_username, nt_username, '') [OS User],	
	coalesce(username, server_principal_name, '')  [SQL Username],
	case when ErrorNumber is null then 'Success' 
	   else 'Failure' end [Outcome],
	count(*) [Count]
from ExtendedEvents
where datediff(day, Corrected_Time, SYSDATETIME()) < 7
  -- exclude SQL Server itself
  and username <> 'CODWTR\sqlAgent'
  and username <> 'CODWTR\sqlEngine'
  -- exclude monitoring tools
  and client_app_name not like 'dbatools Power%'
  and (client_app_name <> '.Net SqlClient Data Provider' and nt_username <> 'CODWTR\cmadmin' and Client_Hostname <> 'WTR320MSDNCM')
group by server_instance_name, database_name, client_hostname, 
	case when client_app_name like 'ArcGIS:%' then 'ArcGIS'
		when client_app_name like 'SDE:%' then 'SDE'
		when client_app_name like 'Microsoft SQL Server Management%' then 'MS SSMS'
		else client_app_name end,
	coalesce(session_nt_username, nt_username, ''), coalesce(username, server_principal_name, ''),
	case when ErrorNumber is null then 'Success' 
	   else 'Failure' end
;
/*
(No column name)	(No column name)
2019-06-03 15:09:59.8300	40032


select datediff(MINUTE, corrected_time,sysdatetime()), corrected_time
  from ExtendedEvents;

--select count(* ) from ExtendedEvents



Where DATEDIFF(ms, d.value(N'(/event/@timestamp)[1]', N'datetimeoffset(4)'), cast('2019-06-03 18:36:00.0000 +00:00' as datetimeoffset(4))) < 0
  and DATEDIFF(ms, d.value(N'(/event/@timestamp)[1]', N'datetimeoffset(4)'), cast('2019-06-03 18:39:00.0000 +00:00' as datetimeoffset(4))) >= 0 


  and DATEDIFF(ms, d.value(N'(/event/@timestamp)[1]', N'datetimeoffset(4)'), cast('2019-06-03 18:39:00.0000 +00:00' as datetimeoffset(4))) >= 0 

  select sysdatetimeoffset

Where DATEDIFF(ms, d.value(N'(/event/@timestamp)[1]', N'datetimeoffset(4)'), cast('2019-06-03 18:36:00.0000 +00:00' as datetimeoffset(4))) < 0
  and DATEDIFF(ms, d.value(N'(/event/@timestamp)[1]', N'datetimeoffset(4)'), cast('2019-06-03 18:39:00.0000 +00:00' as datetimeoffset(4))) >= 0 
*/