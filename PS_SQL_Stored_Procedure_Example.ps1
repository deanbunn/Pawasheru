<#
   PS_SQL_Stored_Procedure_Example.ps1
#>

#Var for SQL Server FQDN 
[string]$SQLServerFQDN = "MySQLServer.mycollege.edu";

#Var for SQL Instance Name
[string]$SQLInstance = "MyInstanceName";

#Var for SQL Database
[string]$SQLDatabase = "MyDatabaseName";

#Var for Insert Stored Procedure Name
[string]$spInsertServer = "Insert_New_Test_Server";

#Connection String Settings (Using Integrated Security So No UserID and Password Needed)
[string]$sqlConString = "Server=$SQLServerFQDN\$SQLInstance;Database=$SQLDatabase;Integrated Security=SSPI;";

#Load .NET System.Data DLL
[Void][system.reflection.assembly]::LoadWithPartialName("System.Data");

#Read In the New Server Name
[string]$newServer = Read-Host "Enter New Server's FQDN";

#Check to See If the Name is Null or Empty
if(![string]::IsNullOrEmpty($newServer))
{
    #Compose Message for Choice Prompt
    [string]$message = "Is " + $newServer + " the Correct FQDN?";

    #Prompt Choices and Options
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription("&Yes");
    $no = New-Object System.Management.Automation.Host.ChoiceDescription("&No");
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no);
    #Create Choice Prompt and Assign Reponse Value (Default Set for No)
    $choice = $host.ui.PromptForChoice("New Server", $message, $options, 1);

    #Check to See If User Chose Yes (0=Yes,1=No)
    if($choice -eq 0)
    {
        #Create a SQL Connection Object 
        $sqlCon = New-Object System.Data.SqlClient.SqlConnection($sqlConString);

        #Create and Configure a SQL Command
        $sqlCommSI = New-Object System.Data.SqlClient.SqlCommand($spInsertServer,$sqlCon);

        #Set the Command Type as a Stored Procedure
        $sqlCommSI.CommandType = [System.Data.CommandType]::StoredProcedure;

        #Add Required Parameters (In This Case Just the Server Name)
        [Void]$sqlCommSI.Parameters.Add("@serverName", [System.Data.SqlDbType]::NVarChar);
        $sqlCommSI.Parameters["@serverName"].Value = $newServer.ToUpper();

        #Open the SQL Connection
        $sqlCon.Open();

        #Execute Insert Stored Procedure
        $cmdStatus = $sqlCommSI.ExecuteNonQuery();

        #Close the SQL Connection
        $sqlCon.Close();

        #Check to See If Command Successfully Completed
        if($cmdStatus -eq 1)
        {
            Write-Output "Command Completed Successfully";
        }
        else
        {
            Write-Output "No Go At This Station";
        }
        
    }
    else
    {
        Write-Output "Please Start Script Over";
    }#End of Choice Check
}
else
{
    Write-Output "Nothing Entered. Please Start Script Over";
}#End of New Server Name Null or Empty Check