<#
Script: AD_Export_OU_Structure.ps1
Author: Dean Bunn
Last Edited: 09/01/13
Description: Export the OU structure between two domains.
Notes: We only needed a few of the source base OUs exported and not the whole domain. 
       The source OUs had hundreds of various nested level OUs underneath them. 
       The base target OU needs to be created first and DN values of the OUs are case sensitive. 
       The script can be run numerous time and will only create OUs in the target OU for OUs that don't exist.
#>

#Create a HashTable to Hold OUs
$htOU = @{};

#Add Source and Target OU Pairs
$htOU["OU=PEOPLE,DC=OldDept,DC=myCollege,DC=edu"] = "OU=PEOPLE,OU=NewDept,DC=childDomain,DC=myCollege,DC=edu";
$htOU["OU=RESEARCH,DC=OldDept,DC=myCollege,DC=edu"] = "OU=RESEARCH,OU=NewDept,DC=childDomain,DC=myCollege,DC=edu";
$htOU["OU=EQUIPMENT,DC=OldDept,DC=myCollege,DC=edu"] = "OU=EQUIPMENT,OU=NewDept,DC=childDomain,DC=myCollege,DC=edu";


#Loop Through the OU HashTable
foreach($key in $htOU.keys)
{
       
    #Vars for OU DNs
    [string]$srcOUDN = $key.ToString();
    [string]$tgtOUDN = $htOU[$key].ToString().Trim();
    #Var for DN Path to Remove When Creating New Target OUs
    [string]$rmvPath = "," + $tgtOUDN;
    
    #Array To Hold Source OU DNs
    $arrSrcOUs = @();
    
    #Vars for ADsPath of Source and Target OUs
    [string]$srcADsPath = "LDAP://" + $srcOUDN;
    [string]$tgtADsPath = "LDAP://" + $tgtOUDN;
    
    #Retrieve Directory Entries for Source and Target OU
    $deSourceOU = [ADSI]$srcADsPath;
    $deTargetOU = [ADSI]$tgtADsPath;
    
    #Search Source OU for All OUs (Excluding Source OU)
    $dsSearch = New-Object DirectoryServices.DirectorySearcher($deSourceOU);
    $dsSearch.filter = "(&(objectClass=organizationalUnit)(!(distinguishedName=$srcOUDN)))";
    $dsSearch.PageSize = 900;
    $dsSearch.SearchScope = "SubTree";
    $srResults = $dsSearch.Findall();

    #Loop Through All Source OU Search Results
    foreach($srResult in $srResults)
    {      
        #Pull Directory Entry for Search Result and Store DN in Source OU Array
        $deOU = $srResult.GetDirectoryEntry();
        $arrSrcOUs += $deOU.distinguishedName.ToString();
    }
    
    #Loop Through Source OUs DN Values
    foreach($srcOU in $arrSrcOUs)
    {
        #Var for Target OU DN Path (Replacing Source OU Path with Target OU Path)
        [string]$uTgtOUDN = $srcOU.ToString().Replace($srcOUDN,$tgtOUDN);
        #Var for Target OU ADsPath (Used for Checking Existance)
        [string]$uTgtOUADsPath = "LDAP://" + $uTgtOUDN;
        
        #Check to See If Target OU Exists. If Not Create It.
        if(![ADSI]::Exists($uTgtOUADsPath))
        {
            #Add New OU and Save
            $newOU = $deTargetOU.create("organizationalUnit",$uTgtOUDN.Replace($rmvPath,""));
            $newOU.setInfo();
        }
                
    }#End of $arrSrcOUs Foreach

}#End of $htOU.keys Foreach

######### End of Script #############
