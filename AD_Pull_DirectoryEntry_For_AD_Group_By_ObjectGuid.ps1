<#
	AD_Pull_DirectoryEntry_For_AD_Group_By_ObjectGuid.ps1
#>

###############################################
# Directory Entry for AD Group By Object Guid
###############################################

#Object Guid for AD Group is ad81120b-711c-43c9-95e6-e6c13408bb38

#Retrieve Directory for Group Object
$deMyMovingADGroup = New-Object DirectoryServices.DirectoryEntry("LDAP://mycollege.edu/<GUID=ad81120b-711c-43c9-95e6-e6c13408bb38>");

#Null Check on Directory Entry for Group
if($deMyMovingADGroup)
{
	#View DN of Group
	Write-Output $deMyMovingADGroup.Properties["distinguishedname"][0].ToString();
	
	#View Direct Membership
	foreach($mbrDN in $deMyMovingADGroup.Properties["member"])
	{
		Write-Output $mbrDN;
	}
}

#######################################
# Quickly Pull a Group's Object Guid 
#######################################

#Var for DN of AD Group
[string]$MovingGroupDN = "CN=AllFacultyAndStaff,OU=IT-GROUPS,OU=IT,OU=COE,OU=DEPARTMENTS,DC=mycollege,DC=edu";

#Retrieve Object Guid for Group by DN
(Get-ADGroup -Identity $MovingGroupDN -Server mycollege.edu:3268).objectGuid.ToString();


