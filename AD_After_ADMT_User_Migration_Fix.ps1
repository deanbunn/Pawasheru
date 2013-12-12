<#
Script Name: AD_After_ADMT_User_Migration_Fix.ps1
Version: 1.0
Author: Dean Bunn
Last Edited: 03/03/2013
Description: Corrects ADMT Account Changes Regarding Password Settings
Notes: If you used Microsoft's Active Directory Migration Tool (ADMT) for any major migrations, then you know that migrated AD 
       accounts are always set for user must change password upon next login. Well in the target domain we didn't want this 
       setting set due to were migrating the password from the old domain and had complexity filter set so ADMT logs would 
       tell us which accounts didn't meet the password criteria. 
#>

#Create NTAccounts for SELF and Everyone
$ntaSelf = New-Object System.Security.Principal.NTAccount("NT AUTHORITY","SELF");
$ntaEveryone = New-Object System.Security.Principal.NTAccount("Everyone");

#AD Security Types
$actDeny = [System.Security.AccessControl.AccessControlType]::Deny;
$adrER = [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight;

#GUID for Change Password AD Property
$gapCP = [Guid]"ab721a53-1e2f-11d0-9819-00aa0040529b";

#Create AD Deny Rules
$adrlDSPC = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($ntaSelf,$adrER,$actDeny,$gapCP);
$adrlDEPC = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($ntaEveryone,$adrER,$actDeny,$gapCP);

#Array of OUs to Run Against
$adOUs = @("OU=People,DC=myCollege,DC=edu",
           "OU=External,DC=myCollege,DC=edu");

#Var for Counting Accounts Checked
$nActCkd = 0;

foreach($adOU in $adOUs)
{
    #Var for OU ADsPath
    [string]$ouADsPath = "LDAP://" + $adOU;
    $deADOU = [ADSI]$ouADsPath;
    $dsSearch = New-Object DirectoryServices.DirectorySearcher($deADOU);
    $dsSearch.filter = "(&(objectClass=user)(sAMAccountName=*)(!objectClass=computer)(!objectClass=contact))";
    $dsSearch.PageSize = 900;
    $dsSearch.SearchScope = "SubTree";
    $srResults = $dsSearch.Findall();
    
    #Loop Through Search Results
    foreach($srResult in $srResults)
    {
        #Null Check on Search Result
        if($srResult)
        {
            #Increment Counting and Display Current Number
            $nActCkd++
            Write-Output $nActCkd.ToString();
            
            #Pull Directory Entry
            $deADUser = $srResult.GetDirectoryEntry();
            
            #Null Check on Directory Entry for User
            if($deADUser)
            {
                $deADUser.psbase.ObjectSecurity.AddAccessRule($adrlDSPC);
                $deADUser.psbase.ObjectSecurity.AddAccessRule($adrlDEPC);
                $deADUser.psbase.commitchanges();
                
                #Set Account to Not Expire (If Necessary)
                #$deADUser.accountExpires = 0;
                #$deADUser.setInfo();
            
                #Var for Account Status 
                [int]$uUAC = [int]::Parse($deADUser.userAccountControl.ToString());
        
                #Check for UAC Setting.
                switch($uUAC)
                {
                
                    512
                    {
                        #Set Password Never Expires
                        $deADUser.userAccountControl = 66048;
                        $deADUser.setInfo();
                    }
                
                    514
                    {
                        #Set Password Never Expires
                        $deADUser.userAccountControl = 66050;
                        $deADUser.setInfo();
                    }
                    
                    544 
                    {
                        #Set Password Never Expires
                        $deADUser.userAccountControl = 66048;
                        $deADUser.setInfo();
                    }
                    
                    546
                    {
                        #Set Password Never Expires
                        $deADUser.userAccountControl = 66050;
                        $deADUser.setInfo();
                    }
                    
                    66080 
                    { 
                        #Set Password Never Expires
                        $deADUser.userAccountControl = 66048;
                        $deADUser.setInfo();
                    }
                    
                    66082 
                    { 
                        #Set Password Never Expires
                        $deADUser.userAccountControl = 66050;
                        $deADUser.setInfo();
                    }
                        
                }#End of userAccountControl Switch
                
            }#End of Null Check on $deADUser
            
        }#End of Null Check on $srResult
        
    }#End of $srResults Foreach
    
}#End of $adOUs Foreach
