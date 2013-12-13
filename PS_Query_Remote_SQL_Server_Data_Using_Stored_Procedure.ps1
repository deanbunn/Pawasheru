<#
   PS_Query_Remote_SQL_Server_Data_Using_Stored_Procedure.ps1
#>

#Var for SQL Server FQDN 
$SQLServerFQDN = "MySQLServer.mycollege.edu";

#Var for SQL Instance Name
$SQLInstance = "MyInstance";

#Var for SQL Database
$SQLDatabase = "MyDatabase";

#Create Empty Array for Storing Server Names
$servers = @();

#Load .NET System.Data DLL
[Void][system.reflection.assembly]::LoadWithPartialName("System.Data");

#Connection String Settings (Using Integrated Security So No UserID and Password Needed)
$sqlConString = "Server=$SQLServerFQDN\$SQLInstance;Database=$SQLDatabase;Integrated Security=SSPI;";

#Stored Procedure Name for Servers Select Statement
$spSelectServers = "Get_All_Servers";

#Create a SQL Connection Object 
$sqlCon = New-Object System.Data.SqlClient.SqlConnection($sqlConString);

#Create and Configure a SQL Command
$sqlCommSR = New-Object System.Data.SqlClient.SqlCommand($spSelectServers,$sqlCon);

#Set the Command Type as a Stored Procedure
$sqlCommSR.CommandType = [System.Data.CommandType]::StoredProcedure;

#Open the SQL Connection
$sqlCon.Open();

#Execute the Command
$sqlRdrSR = $sqlCommSR.ExecuteReader();

#Read Through the Returned Data
#This Specific Stored Procedure Returns a "Server_Name" Column
while ($sqlRdrSR.Read()) 
{
    $servers += $sqlRdrSR["Server_Name"].ToString().Trim();
}

##Close the SQL Reader and Connection
$sqlRdrSR.close();
$sqlCon.close();

#Loop Through Array and Output Server Name
foreach($server in $servers)
{
    Write-Output $server;
}