clear-host
#  https://www.sqlhammer.com/query-central-management-server-with-powershell-smo/

Import-Module SQLPS -DisableNameChecking

Function Parse-ServerGroup($serverGroup)
{
    $results = $serverGroup.RegisteredServers;
    foreach($group in $serverGroup.ServerGroups)
    {
        $results += Parse-ServerGroup -serverGroup $group;
    }
    return $results;
}
Function Get-ServerList ([string]$cmsName, [string]$serverGroup, [switch]$recurse)
{
    $connectionString = "data source=$cmsName;initial catalog=master;integrated security=sspi;"
    $sqlConnection = New-Object ("System.Data.SqlClient.SqlConnection") $connectionstring
    $conn = New-Object ("Microsoft.SQLServer.Management.common.serverconnection") $sqlconnection
    $cmsStore = New-Object ("Microsoft.SqlServer.Management.RegisteredServers.RegisteredServersStore") $conn
    $cmsRootGroup = $cmsStore.ServerGroups["DatabaseEngineServerGroup"].ServerGroups[$serverGroup]

    if($recurse)
    {
        return Parse-ServerGroup -serverGroup $cmsRootGroup | select ServerName
    }
    else
    {
        return $cmsRootGroup.RegisteredServers | select ServerName
    }
}

$serverList = Get-ServerList -cmsName ‘INSTANCE’ -serverGroup "Dev Servers" -recurse
$serverList | Format-Table

# https://www.sqlshack.com/backup-testing-powershell-part-1-test/