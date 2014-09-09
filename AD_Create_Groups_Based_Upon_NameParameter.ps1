<#
	Script Name: AD_Create_Groups_Based_Upon_NameParameter.ps1
	Author: Dean Bunn
	Last Edited: 09/08/14
	Description: A Colleague Requested a Way to Create Three AD Groups 
	             Based Upon a Database Name Parameter
#>

#Input Parameter for SOE Database Name
param ([string]$SOEDatabase = $(throw "Database Name Required"));

#Var for SOE OU Distinguished Name
[string]$ouSOE = "OU=FM-Databases,OU=SOE-Applications,OU=SOE,OU=Units,DC=MyCollege,DC=edu";

#Remove Spaces From SOE Database Name
$SOEDatabase = $SOEDatabase.Replace(" ","");

#Compose Message for Choice Prompt
[string]$message = "Create AD groups based upon database name """ + $SOEDatabase + """?";

#Prompt Choices and Options
$yes = New-Object System.Management.Automation.Host.ChoiceDescription("&Yes");
$no = New-Object System.Management.Automation.Host.ChoiceDescription("&No");
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no);
#Create Choice Prompt and Assign Reponse Value (Default Set for No)
$choice = $host.ui.PromptForChoice("SOE Database Groups", $message, $options, 1);

#Check to See If User Chose Yes (0=Yes,1=No)
if($choice -eq 0)
{
	#Var for SOE OU ADsPath
	[string]$ouADsPath = "LDAP://" + $ouSOE;

	#Directory Entry for SOE OU 
	$deSOEOU = [ADSI]$ouADsPath;

	#Null\Empty Check on SOE Database Name
	if(![string]::IsNullOrEmpty($SOEDatabase))
	{
		#Vars for AD Test Paths
		[string]$admGrpADsPath = ("LDAP://CN=SOE-US-Db-?Admin").Replace("?",$SOEDatabase) + "," + $ouSOE;
		[string]$edtGrpADsPath = ("LDAP://CN=SOE-US-Db-?Editor").Replace("?",$SOEDatabase) + "," + $ouSOE;
		[string]$rdrGrpADsPath = ("LDAP://CN=SOE-US-Db-?ReadOnly").Replace("?",$SOEDatabase) + "," + $ouSOE;
		
		#Check to See If Db Admin Group Exists. If Not Create It.
		if(![ADSI]::Exists($admGrpADsPath))
		{
			Write-Output "Creating Admin Group";
		    #Create the DB Admins Group
			$dbAdmins = $deSOEOU.create("group",("CN=SOE-US-Db-?Admin").Replace("?",$SOEDatabase));
			$dbAdmins.Put("sAMAccountName",("SOE-US-Db-?Admin").Replace("?",$SOEDatabase));
			$dbAdmins.psbase.InvokeSet("groupType",-2147483648 + 8); #As Universal
			$dbAdmins.setInfo();
			$dbAdmins.Description = ("Grants Admin permissions to the ? Database").Replace("?",$SOEDatabase);
			$dbAdmins.setInfo();
		}
		else
		{
			Write-Output "DB Admin Group Already Exists";
		}#End of Db Admins Group Check

		#Check to See If Db Editor Group Exists. If Not Create It.
		if(![ADSI]::Exists($edtGrpADsPath))
		{
			Write-Output "Creating Editor Group";
			#Create the DB Editor Group
			$dbEditors = $deSOEOU.create("group",("CN=SOE-US-Db-?Editor").Replace("?",$SOEDatabase));
			$dbEditors.Put("sAMAccountName",("SOE-US-Db-?Editor").Replace("?",$SOEDatabase));
			$dbEditors.psbase.InvokeSet("groupType",-2147483648 + 8); #As Universal
			$dbEditors.setInfo();
			$dbEditors.Description = ("Grants Editor permissions to the ? Database").Replace("?",$SOEDatabase);
			$dbEditors.setInfo();
		}
		else
		{
			Write-Output "DB Editor Group Already Exists";
		}#End of Db Editors Group Check
		
		#Check to See If Db Read Only Group Exists. If Not Create It.
		if(![ADSI]::Exists($rdrGrpADsPath))
		{
			Write-Output "Creating Read Only Group";
			#Create the DB Readers Group
			$dbReadOnly = $deSOEOU.create("group",("CN=SOE-US-Db-?ReadOnly").Replace("?",$SOEDatabase));
			$dbReadOnly.Put("sAMAccountName",("SOE-US-Db-?ReadOnly").Replace("?",$SOEDatabase));
			$dbReadOnly.psbase.InvokeSet("groupType",-2147483648 + 8); #As Universal
			$dbReadOnly.setInfo();
			$dbReadOnly.Description = ("Grants Read Only permissions to the ? Database").Replace("?",$SOEDatabase);
			$dbReadOnly.setInfo();
		}
		else
		{
			Write-Output "DB Read Only Group Already Exists";
		}
		
	}#End of SOEDatabase Null\Empty Check

	#Notify User of Script Completion
	Write-Output "All Done";

}
else
{
	Write-Output "You Said No. Please Start Script Over";
}#End of Choice

####################################
# End of Script
####################################


