########################################################################
# Script Name: AD_User_Acct_Audit.ps1
# Version: 1.0
# Author: Dean Bunn
# Last Edited: 06/09/2011
# Description: Reports Account Creation Date and Last Password Set
#               for Individual User
########################################################################

#Required userID Parameter
param ([string] $userID = $(throw "userID required"))

#Error Message to Inform User of Correct userID Format
function IncorrectInfo()
{
  Write-Host ""
  Write-Host "Incorrect Parameter Format! Example: -userID jsmith@my.campus.edu"
  Write-Host ""
  exit
}

#Variables for LDAP Query 
$strUserID = ""
$strDomain = ""
$strLDAP = "LDAP://"

#Various Checks to See if userID is in Correct Format
if($userID.ToString().Contains("@"))
{
  #Create Array Based Upon userID Parameter
  $arrUserID = $userID.Split("@")
  
  #Check to See if Only One "@" was Used
   if($arrUserID.Count -eq 2)
   {
      #Parse User ID Info
      $strUserID = $arrUserID[0].ToString().Trim()
      $strDomain = $arrUserID[1].ToString().Trim()
    
      #Insure Something was on Both Sides of the "@"
      if($strUserID.Length -gt 0 -and $strDomain.Length -gt 0)
      {
        
        #Parse Domain Info and Create LDAP Path
         if($strDomain.ToString().Contains("."))
         {
            #Create Array Based Upon Domain Info
            $arrDomain = $strDomain.Split(".")
            
            #Format LDAP Path String
            foreach($dm in $arrDomain)
            {
              $strLDAP = $strLDAP + "DC=" + $dm + ","
            }
            #Remove Extra "," 
            $strLDAP = $strLDAP.Trim().TrimEnd(",")
            
            #Attempt AD Query
            try
            {  
               
               #AD Search for Specific Account
               $ADsPath = [ADSI]$strLDAP
               $Search = New-Object DirectoryServices.DirectorySearcher($ADsPath)
               $Search.filter = "(&(objectClass=user)(sAMAccountName=" + $strUserID + "))"
               #Search Entire AD Tree
               $Search.SearchScope = "SubTree"
               $Result = $Search.FindOne()
             
               #Check to See if AD Query Results Not Null
               if($Result)
               {
                  #Retrieve AD Account
                  $objUser = $result.GetDirectoryEntry()
                  
                  #Convert Account Creation Time to Local Time
                  $cd = [System.DateTime]::Parse($objUser.whenCreated.ToString())
                  $actCD = $cd.AddHours(-7)
                  
                  #Checking to See If Password Has Actually Been Changed
                  #Password Last Set Info is Only Returned in Initial Search Results
                  if(($Result.Properties["pwdlastset"][0].ToString() -ne "9223372036854775807") -and 
                    ($Result.Properties["pwdlastset"][0].ToString() -ne "0"))
                  {
                    $pwdSetDate = [System.DateTime]::FromFileTime($Result.Properties["pwdlastset"][0])
                  }
                  else
                  {
                    $pwdSetDate = "Not Set"
                  }
                  
                  #Create Object,Assign Data to It, Then Display It
                  $objAudit = new-Object PSObject
                  $objAudit | add-Member -memberType noteProperty -name "UserID" -Value $objUser.SamAccountName.ToString()
                  $objAudit | add-Member -memberType noteProperty -name "Creation Date" -Value $actCD.ToString()
                  $objAudit | add-Member -memberType noteProperty -name "Password Last Set" -Value $pwdSetDate.ToString()
                  $objAudit | ft
                  
                }
                else
                {
                   Write-Host ""
                   Write-Host $userID "Couldn't Be Found On Domain!"
                   Write-Host ""
                   exit
                }
            
             }
             catch
             {
                Write-Host ""
                Write-Host "Error Querying AD Domain" $strDomain.ToUpper() "for" $strUserID.ToUpper()
                Write-Host ""
                exit
             }
            
           }
           else
           {
             IncorrectInfo
           }
          
      }
      else
      {
        IncorrectInfo
      }
      
   }
   else
   {
      IncorrectInfo
   }
  
}
else
{
  IncorrectInfo
}
