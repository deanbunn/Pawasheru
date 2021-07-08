<#
   Script: GPO_Find_Specific_AD_Objects_Listed.ps1
   Author: Dean Bunn
   Last Edit: 2021-07-08
#>


#Array of AD Object Names
$arrADObjectNames = @("COE-US-XXXXXXXX-Users","COE-US-XXXXXXXXXX-Admins");
    
#Import Group Policy Module 
Import-Module GroupPolicy;

#Var for ADsPath of Parent OU
[string]$parentOUADsPath = "LDAP://OU=XXXX,OU=XXXXXXX,DC=XXXX,DC=XXXX,DC=XXXXXX,DC=edu";

#Array for OU DNs
$arrOUDNs = @();

#HashTable for GPO IDs
$htGPOIDs = @{};

#HashTable for GPO Ids to Ignore
$htIgnoreGPOs = @{};
$htIgnoreGPOs.Add("8532ae13-4d1e-459e-aa76-60890811151b","1");

#Pull Directory Entry for Main OU
$deParentOU = [ADSI]$parentOUADsPath;

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

    #Create Custom AD OU Object
	$cstOU = new-object PSObject -Property (@{ ou_dn=""; gpo_ids=@();});
    $cstOU.ou_dn = $deSROU.distinguishedName.ToString()

    #Add Custom Object to OU Array
    $arrOUDNs += $cstOU;

}#End of $srOUResults Foreach

#Loop Through OU DNs to Pull GPO IDs
foreach($ouDN in $arrOUDNs)
{

    #Retrieve All Linked GPOs for OU DN
	$lnkdGPOs = Get-GPInheritance -target $ouDN.ou_dn;

    #Loop Through All Directly Linked GPOs
	foreach($lnkdGPO in $lnkdGPOs.GpoLinks)
	{

        #Check for Linked GPO Guids to Ignore
        if($htIgnoreGPOs.ContainsKey($lnkdGPO.GpoId.ToString()) -eq $false)
        {
            #Add to Linked GPOS
            $ouDN.gpo_ids += $lnkdGPO.GpoId.ToString();

            #Check for Unique GPO ID
            if($htGPOIDs.ContainsKey($lnkdGPO.GpoId.ToString()) -eq $false)
            {
                $htGPOIDs.Add($lnkdGPO.GpoId.ToString(),"1");
            }

        }#End of GPO to Ignore Check
        
    }#End of $lnkdGPOs.GpoLinks Foreach

}#End of $arrOUDNs Foreach

#Loop Through GPO IPs and Pull GPO Settings 
foreach($gpoID in $htGPOIDs.Keys)
{

    #Convert to Guid Object to Pull GPO Settings
    $gpoGuid = [GUID]$gpoID;

    #Pull GPO 
    $ucdGPO = Get-GPO -Guid $gpoGuid;
    
    #Pull GPO HTML Report
    [string]$gpoHTMLReport = Get-GPOReport -Guid $gpoGuid -ReportType Html;

    #Check for Each Term in the HTML Report Object
    foreach($srchADObjName in $arrADObjectNames)
    {

        if($gpoHTMLReport.ToLower().Contains($srchADObjName.ToString().ToLower()) -eq $true)
        {
            Write-Output ("found term " + $srchADObjName + " in " + $ucdGPO.DisplayName);
        }

    }#End of $arrADObjectNames Foreach
    
}#End of GPO IDs to Check

