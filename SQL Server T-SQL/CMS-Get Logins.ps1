$sql = "Use master select sysdatetime()"
 
 clear-host
 ## https://www.red-gate.com/simple-talk/databases/sql-server/tools-sql-server/registered-servers-and-central-management-server-stores/ 

#Load SMO assemblies
$CentralManagementServer = "instance"
$MS='Microsoft.SQLServer'
@('.SMO', '.Management.RegisteredServers', '.ConnectionInfo') |
 foreach-object {if ([System.Reflection.Assembly]::LoadWithPartialName("$MS$_") -eq $null) {"missing SMO component $MS$_"}}
 
 
$connectionString = "Data Source=$CentralManagementServer;Initial Catalog=master;Integrated Security=SSPI;"
$sqlConnection = new-object System.Data.SqlClient.SqlConnection($connectionString)
$conn = new-object Microsoft.SqlServer.Management.Common.ServerConnection($sqlConnection)
$CentralManagementServerStore = new-object Microsoft.SqlServer.Management.RegisteredServers.RegisteredServersStore($conn)
 
 
$My="$ms.Management.Smo" #
$CentralManagementServerStore.ServerGroups[ "DatabaseEngineServerGroup" ].GetDescendantRegisteredServers() |
 foreach-object {new-object ("Microsoft.SqlServer.Management.Smo.Server") $_.ServerName } | # create an SMO server object
 Where-Object {$_.ServerType -ne $null} | # did you positively get the server?
 Foreach-object {$_.Logins } | #logins for every server successfully reached 
 Select-object @{Name="Server"; Expression={$_.parent}}, Name, DefaultDatabase , CreateDate, DateLastModified |
 format-table