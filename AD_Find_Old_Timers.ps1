<#
Script Name: AD_Find_Old_Timers.ps1
Version: 1.0
Author: Dean Bunn
Last Edited: 03/08/2013
Description: Finds Old AD Accounts (in specific OUs) Older than Four Years Old
             with Passwords that have Never been Changed
             or are Older than Four Years Old
#>

#Create DateTime Object for Four Years Ago
$dt4YrsAgo = (Get-Date).AddYears(-4);

#Var for Converted File Time Used for Password Last Set Filter 
$ftPLS = $dt4YrsAgo.ToFileTime().ToString();

#Constructing When Created Filter(Should Look Like 20130302000000.0Z)
$wcYear = $dt4YrsAgo.Year.ToString();
$wcMonth = "{0:D2}" -f $dt4YrsAgo.Month;
$wcDay = "{0:D2}" -f $dt4YrsAgo.Day;
$sWC = $wcYear + $wcMonth + $wcDay + "000000.0Z";

#Reporting Array
$report = @();

#Var for Showing Progress
$x = 0;

#Array of OUs to Check Against
$arrOUs = @("LDAP://OU=External,DC=MyCollege,DC=edu",
            "LDAP://OU=Students,DC=MyCollege,DC=edu",
            "LDAP://OU=Staff,DC=MyCollege,DC=edu");

foreach($ouADsPath in $arrOUs)
{
    
    #Directory Entry for OU to Search
    $deOU = [adsi]$ouADsPath;
    
    #Search OU for All User Accounts Meeting the Search Criteria
    $dsSearch = New-Object DirectoryServices.DirectorySearcher($deOU);
    $dsSearch.filter = "(&(objectClass=user)(sAMAccountName=*)(whenCreated<=$sWC)(|(pwdlastset<=$ftPLS)(pwdlastset=0)(pwdlastset=9223372036854775807)))";
    $dsSearch.PageSize = 900;
    $dsSearch.SearchScope = "SubTree";
    $srResults = $dsSearch.Findall();
        
    #Loop Through All Search Results
    foreach($srResult in $srResults)
    {   
    
        $x++;
        Write-Output $x.ToString();
        
        #Retrieve DirectoryEntry for the User Account
        $deADUser = $srResult.GetDirectoryEntry();
        
        #Null Check on the DirectoryEntry Object
        if($deADUser)
        {
            #Create Custom Object for Reporting
            $cstPCUser = New-Object PSObject;
            $cstPCUser | Add-Member -MemberType NoteProperty -Name "UserID" -Value "";
            $cstPCUser | Add-Member -MemberType NoteProperty -Name "UPN" -Value "";
            $cstPCUser | Add-Member -MemberType NoteProperty -Name "CN" -Value "";
            $cstPCUser | Add-Member -MemberType NoteProperty -Name "UAC" -Value ""
            $cstPCUser | Add-Member -MemberType NoteProperty -Name "PasswordChanged" -Value "";
            $cstPCUser | Add-Member -MemberType NoteProperty -Name "LastLoginTimeStamp" -Value "";
            
            #Pull Basic Account Information
            $cstPCUser.UserID = $deADUser.sAMAccountName.ToString().ToLower();
            $cstPCUser.UPN = $deADUser.userPrincipalName.ToString().ToLower();
            $cstPCUser.CN = $deADUser.cn.ToString();
            
            #Check Last Password Change
            if($srResult.Properties["pwdlastset"][0].ToString() -ne "9223372036854775807" -and $srResult.Properties["pwdlastset"][0].ToString() -ne "0")
            {
                $cstPCUser.PasswordChanged = ([System.DateTime]::FromFileTime($srResult.properties["pwdlastset"][0])).ToString();
            }
            else
            {
                $cstPCUser.PasswordChanged = "Not Set";
            }
            
            #Account Status Check
            if($deADUser.userAccountControl)
            {
                
                switch([int]($deADUser.userAccountControl.ToString()))
                {
                   512 {$cstPCUser.UAC = "Enabled"}
                   514 {$cstPCUser.UAC = "Disabled"}
                   520 {$cstPCUser.UAC = "Enabled"}
                   522 {$cstPCUser.UAC = "Disabled"}
                   544 {$cstPCUser.UAC = "Enabled"}
                   546 {$cstPCUser.UAC = "Disabled"}
                   66048 {$cstPCUser.UAC = "Enabled"}
                   66050 {$cstPCUser.UAC = "Disabled"}
                   66080 {$cstPCUser.UAC = "Enabled"}
                   66082 {$cstPCUser.UAC = "Disabled"}
                   8388608 {$cstPCUser.UAC = "Password Expired"}
                   default {$cstPCUser.UAC = "unknown"}
                }
            }
       
               #Convert Last Logon Timestamp (If Exists)
            if($srResult.Properties["lastlogontimestamp"])
            {
                $cstPCUser.LastLoginTimeStamp = ([System.DateTime]::FromFileTime($srResult.Properties["lastlogontimestamp"][0])).ToShortDateString();
            }
            
            #Add Custom Object to Report Collection
            $report += $cstPCUser;
            
        }#End of $deADUser Null Check
        
    }#End of $srResults Foreach
    
}#End of $arrOUs Foreach


#Get Current Short Date
$rptFileDate = Get-Date -Format d;
        
#Var for CSV File Name
$fileName = "Old_Timers_Password_Change_Report_" + $rptFileDate.ToString().Replace("/","-") + ".csv";
        
#Export CSV Report
$report | Sort-Object UserID | Export-CSV $fileName -NoTypeInformation ;

###### End of Script ###################