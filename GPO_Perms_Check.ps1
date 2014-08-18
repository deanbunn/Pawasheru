<#
	Script: GPO_Perms_Check.ps1
	Author: Dean Bunn
	Last Edited: 08/17/14
	Description: Checks to See If a Specific AD Group has at least edit access
				 to all GPOs linked to a Specific OU (and all sub OUs)
#>

#Import Group Policy Module 
Import-Module GroupPolicy;

#Var for DN of Parent OU to Check
[string]$parentOUDN = "OU=MyDept,OU=DEPARTMENTS,DC=mycollege,DC=edu";

#Var for DN of Admin Group to Check for
[string]$adminGroupDN = "CN=DeptAdmins,OU=MyDept,OU=DEPARTMENTS,DC=mycollege,DC=edu";

#Array of Techs Contacts
$Techs = @("myadminlist@mycollege.edu");

#Get Current Short Date
$rptDate = Get-Date -Format d

#Vars for Report Email Notice
[string]$msgSubject = "Group Policy Objects Permissions Report for " + $rptDate;
[string]$msgFrom = "myautomationaccount@mycollege.edu>";
[string]$smtpServer = "smtp.mycollege.edu";
[string]$msgBody = "<html><body><h3>Group Policy Objects Permissions Report</h3>";

#Var for ADsPath of Parent OU
[string]$parentOUADsPath = "LDAP://" + $parentOUDN;

#Var for ADsPath of Admin Group
[string]$admnGrpADsPath = "LDAP://" + $adminGroupDN;

#Var for Display Name of Admin Group
[string]$admnGrpName = "";

#Array for OU DNs
$arrOUDNs = @();

#Array List for GPO Guids
$alGPOGuids = New-Object System.Collections.ArrayList;

#Array List for GPO Guids Needing Perms
$alGPOGuidsNP = New-Object System.Collections.ArrayList;

#Array List for OU Locations with GPOs that We Don't Have Permissions to Even Read
$alOULocsNoRead = New-Object System.Collections.ArrayList;

#Array for Custom GPO Objects
$arrCstGPOs = @();

#Pull Directory Entry for Main OU
$deParentOU = [ADSI]$parentOUADsPath;

#Pull Directory Entry for Admin Group
$deAdminGroup = [ADSI]$admnGrpADsPath;

#Pull Admin Group Name
if($deAdminGroup.properties["displayName"] -ne $null)
{
	$admnGrpName = $deAdminGroup.properties["displayName"][0].ToString();
}
else
{
	$admnGrpName = $deAdminGroup.properties["cn"][0].ToString();
}#End Admin Group Name

#Search Parent OU for All OUs (Including Parent OU)
$dsOUSearch = New-Object DirectoryServices.DirectorySearcher($deParentOU);
$dsOUSearch.Filter = "(objectClass=organizationalUnit)";
$dsOUSearch.PageSize = 900;
$dsOUSearch.SearchScope = "SubTree";
$srOUResults = $dsOUSearch.FindAll();

#Loop Through All OU Search Results
foreach($srOU in $srOUResults)
{
	#Pull Directory Entry for OU Search Result and Store DN in Array
	$deSROU = $srOU.GetDirectoryEntry();
    $arrOUDNs += $deSROU.distinguishedName.ToString();
}#End of $srOUResults Foreach

#Loop Through OU DNs and Pull Linked GPOs
foreach($ouDN in $arrOUDNs)
{
	#Retrieve All Linked GPOS
	$lnkdGPOs = Get-GPInheritance -target $ouDN;
	
	#Loop Through All Directly Linked GPOs
	foreach($lnkdGPO in $lnkdGPOs.GpoLinks)
	{
		#Check for Empty Display Name Value (GPO that We Have No Perms to Will have Empty Display Names)
	    if([string]::IsNullOrEmpty($lnkdGPO.DisplayName) -eq $false)
		{
			#Check to See If GPO GUID Already In List Before Adding It
			if($alGPOGuids.Contains($lnkdGPO.GpoId.ToString()) -eq $false)
			{
			   [Void]$alGPOGuids.Add($lnkdGPO.GpoId.ToString());
			}
		}
		else
		{
			#Add Location to OU No Read List
			if($alOULocsNoRead.Contains($lnkdGPO.Target.ToString()) -eq $false)
			{
				[Void]$alOULocsNoRead.Add($lnkdGPO.Target.ToString());
			}
		}
		
	}#End of $lnkdGPOs.GpoLinks Foreach
	
}#End of $arrOUDNs Foreach

#Loop Through Each GPO GUID and Check Perms
foreach($gpoGUID in $alGPOGuids)
{

	#Var for Perm Status 
	$bThere = $false;

	#Guid for Retrieving GPO Permissions
	$guidGPO = [Guid]$gpoGUID;
		
	#Pull GPO Perms
	$gpoPerms = Get-GPPermission -Guid $guidGPO -All;

	#Null Check on Perms
	if($gpoPerms)
	{
		#Loop Through Each Assigned Permission
		foreach($gperm in $gpoPerms)
		{
		    #Check to See If Admin Group has Been Assigned At Least Edit to the GPO (GpoEdit or GpoEditDeleteModifySecurity)
			if([string]::IsNullOrEmpty($gperm.Trustee.DSPath) -eq $false `
			   -and [string]::Compare($gperm.Trustee.DSPath,$adminGroupDN,$true) -eq 0 `
			   -and $gperm.Permission.ToString().Contains("GpoEdit"))
			{
				$bThere = $true;
			}
			
		}#End of $gpoPerms Foreach
		
	}#End of $gpoPerms Null Check
	
	#If Perms Not Assigned Then Add GPO Guid to List
	if($bThere -eq $false)
	{
		[Void]$alGPOGuidsNP.Add($guidGPO);
	}
	
}#End of $alGPOGuids

#Loop Through Guids of GPOs with No Edit Perms and Add to Custom Array
foreach($noEditGuid in $alGPOGuidsNP)
{
	#Pull GPO Information
	$neGPO = Get-GPO -guid $noEditGuid 
		
	#Create Custom GPO Object
	$cstGPO = new-object PSObject -Property (@{ DisplayName=""; Owner=""; GPOStatus=""; CreationTime=""; });
	
	#Check Display Name Value
	if([string]::IsNullOrEmpty($neGPO.DisplayName) -eq $false)
	{
		$cstGPO.DisplayName = $neGPO.DisplayName;
	}
	
	#Check Owner Value
	if([string]::IsNullOrEmpty($neGPO.Owner) -eq $false)
	{
		$cstGPO.Owner = $neGPO.Owner;
	}
	
	#Check GPO Status Value
	if([string]::IsNullOrEmpty($neGPO.GpoStatus) -eq $false)
	{
		$cstGPO.GPOStatus = $neGPO.GpoStatus;
	}
	
	#Check Creation Time
	if($neGPO.CreationTime -ne $null)
	{
		$cstGPO.CreationTime = $neGPO.CreationTime.ToString();
	}
	
	#Add Custom Object to Array
	$arrCstGPOs += $cstGPO;
}

if($arrCstGPOs.Count -gt 0 -or $alOULocsNoRead.Count -gt 0)
{
	#Check If Any No Edit Perms GPOs to Report
	if($arrCstGPOs.Count -gt 0)
	{
		#Sort Array
		$arrCstGPOs = $arrCstGPOs | Sort-Object DisplayName;
	
		#Add No Edit Permission Table
		$msgBody +=	  "<table border=""1"" cellpadding=""5"" cellspacing=""2"" style=""font-size:8pt;font-family:Arial,sans-serif"">
		              <tr bgcolor=""#002855"">
                      <td colspan=""4"" align=""center"">
				      <strong><font color=""#D4AC33"" style=""font-size:12pt"">
                      Group Policy Objects that $admnGrpName cannot Edit
                      </font></strong>
				      </td>
                      </tr>
                  	  <tr bgcolor=""#D4AC33"">  
	                  <td><strong><font color=""#002855"">Display Name</font></strong></td>
	                  <td><strong><font color=""#002855"">Owner</font></strong></td>
	                  <td><strong><font color=""#002855"">GPO Status</font></strong></td>
	                  <td><strong><font color=""#002855"">Created</font></strong></td>
                     </tr>";
					 
	    
	    foreach($cstGPO in $arrCstGPOs)
		{
			$msgBody += "<tr><td>" + $cstGPO.DisplayName + "</td><td>" + $cstGPO.Owner `
			          + "</td><td>" + $cstGPO.GPOStatus + "</td><td>" + $cstGPO.CreationTime + "</td></tr>";
		
		}#End of $arrCstGPOs
					 
		$msgBody += "</table>
		             <br />
					 <br />";
		 
	}#End of $arrCstGPOs Count
	
	#Check If Any OU Locations to Report
	if($alOULocsNoRead.Count -gt 0)
	{
	    $alOULocsNoRead.Sort();
	
		#Add OU With GPOs with No Permission Table
		$msgBody +=	  "<table border=""1"" cellpadding=""5"" cellspacing=""2"" style=""font-size:8pt;font-family:Arial,sans-serif"">
		               <tr bgcolor=""#002855"">
                       <td align=""center"">
				       <strong><font color=""#D4AC33"" style=""font-size:12pt"">
                       OU Locations with Linked GPOs that $admnGrpName cannot Read
                      </font></strong>
				      </td>
                      </tr>
                  	  ";
	
		foreach($ouLoc in $alOULocsNoRead)
		{
			$msgBody += "<tr><td>" + $ouLoc + "</td></tr>";
		}#End of $alOULocsNoRead Foreach
	
	    $msgBody += "</table>
		             <br />
					 <br />";
	
	}#End of $alOULocsNoRead Count
	
	#Finish Off Message Body
    $msgBody += "<br />
			     <br />
			     <br />
			     <br />
                </body>
                </html>";
            
#Send Report Email Message 
Send-MailMessage -SmtpServer $smtpServer -Subject $msgSubject -From $msgFrom -To $Techs -Body $msgBody –BodyAsHtml;

}#End of Counts on Report Items

##############################
# End of Script
##############################