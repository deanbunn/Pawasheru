#############################################################
# Script Name: Failed_Login_Report.ps1
# Version: 3.0
# Author: Dean Bunn
# Last Edited: 07/30/2011
# Description: Failed Logins Report for An Array of Servers
#############################################################

#Array for Counting Failed Login Entries
$arrFailures = @();
#Array for All Failed Logins(Used for CSV Report File)
$arrCSVFailures = @();
#Array for Reporting
$Summary = @();
#Var for Email Message Body
$emsg = "";

#Servers Array
$Servers = @("TS-Server1","TS-Server2","TS-Server3");

foreach($Server in $Servers)
{

      #Ping Computer Before Attempting Remote WMI 
      if(test-connection -computername $Server -quiet) 
      {
              
            #Retrieve Failed Logins on Each DC for the Last 24 Hours
            $failedLogins = get-eventlog -computername $Server -logname security -after (get-date).adddays(-1) | where-object {$_.instanceID -eq 4625 };
    
            #Null Check on Failed Logins
            if($failedLogins)
            {
            
                #Loop Through Each Failed Login
                foreach($failedLogin in $failedLogins)
                {
                
                    #Var for Workstation Name
                    $workstation = "";
                    #Var for IP Address
                    $networkAddress = "";
                    #Bolean for Act Check
                    $afwlf = $false;
                    #Var for Account Name
                    $accountName = "";
                    #Var for Domain Name
                    $accountDomain = "";
                
                    #Array of Failed Login Log Entry Message (Split by Line Break)
                    $flM = $failedLogin.message.Split("`n");
            
                    #Loop Through Each Line in the Log Entry Message
                    foreach($fl in $flM)
                    {
                        #Check to See if Line has Source Network Address Info
                          if($fl.Contains("Source Network Address:"))
                          {
                            #Remove Unneeded Data from Line
                              $fl = $fl.Replace("Source Network Address:","");
                            #Clean UP Network Address Info
                              $networkAddress = $fl.ToString().Trim();
                          }
                     
                        #Check to See if Line has Workstation Info 
                          if($fl.Contains("Workstation Name:"))
                          {
                            #Remove Unneeded Data from Line
                             $fl = $fl.Replace("Workstation Name:","");
                            #Clean Up Workstation Info
                              $workstation = $fl.ToString().ToUpper().Trim();
                          }
                    
                        #Check to See if Loop has Progress to the Past the Subject Section Account Name
                        if($fl.Contains("Account For Which Logon Failed:"))
                        {
                               $afwlf = $true;
                        }
                    
                        #Check to See if Line has Second Account Name Info
                        if($fl.Contains("Account Name:") -and $afwlf -eq $true)
                        {
                               #Remove Unneeded Data from Line
                               $fl = $fl.Replace("Account Name:","");
                               #Clean Up Account Name Info
                               $accountName = $fl.ToString().ToUpper().Trim();
                        }
                    
                        #Check to See if Line has Second Account Domain Info
                        if($fl.Contains("Account Domain:") -and $afwlf -eq $true)
                        {
                               #Remove Unneeded Data from Line
                               $fl = $fl.Replace("Account Domain:","");
                               #Clean Up Account Name Info
                               $accountDomain = $fl.ToString().ToUpper().Trim();
                        }
            
                    }
                 
                    #Format Failed Login Entry Data Before Adding to Array 
                    $flEntry = $networkAddress + "," + $workstation;
                
                    #Quick Check to See if IP And Host Name Weren't Empty
                    if($flEntry.length -gt 1)
                    {
                        #Added Failed Entry to Array
                          $arrFailures += $flEntry;
                    }
                
                    #Add All Parsed Failed Entry Info into CSV Report Array
                       $flEntry = new-Object PSObject;
                    $flEntry | add-Member -memberType noteProperty -name "Time Generated" -Value $failedLogin.TimeGenerated.ToString();
                      $flEntry | add-Member -memberType noteProperty -name "IP" -Value $networkAddress.ToString();
                      $flEntry | add-Member -memberType noteProperty -name "Host Name" -Value $workstation.ToString();
                      $flEntry | add-Member -memberType noteProperty -name "Account Name" -Value $accountName.ToString();
                    $flEntry | add-Member -memberType noteProperty -name "Account Domain" -Value $accountDomain.ToString();
                    $flEntry | add-Member -memberType noteProperty -name "Auth Server" -Value $Server.ToString();
                      #Add Entry to CSV Report Array
                      $arrCSVFailures += $flEntry;
                
                }#End of Foreach Failed Login
            
            }#End of Null Check on Failed Logins WMI Object
    
        }#End of Ping Server Test
        
}#End of Foreach Server


#Create Hashtable for Unique Check
$htReport = @{};

#Loop Through Failed Log Entries Array and Count How Many Failed Logins
foreach($flEntry in $arrFailures)
{
    #Int for Counting Failed Login Attempts
       $intEC = 0;
    
    if(!$htReport.ContainsKey($flEntry))
    {
        #Loop Again Through Array Looking for IP + Host Name Match 
           foreach($item in $arrFailures)
           {
              if($flEntry -eq $item)
              {  
                 $intEC = $intEC + 1;
              }
           }
    
        #After Determining Matches, See if Entry Count Added To Report Already
        #And Only Report on 10 or Greater Failed Logins for IP + Host Name Pair
           if($intEC -gt 10) #
           {
        
            #Split Apart IP Host Name Entry to Add It to Report Summary
              $arrFlEntry = $flEntry.Split(",");
      
              #Create New PowerShell Object and Assign Data to It
              $uEntry = new-Object PSObject;
              $uEntry | add-Member -memberType noteProperty -name "IP" -Value $arrFlEntry[0].ToString();
              $uEntry | add-Member -memberType noteProperty -name "Host Name" -Value $arrFlEntry[1].ToString();
              $uEntry | add-Member -memberType noteProperty -name "Failed Logins" -Value $intEC.ToString();
              #Add Entry to Summary Array
              $Summary += $uEntry;
      
           }
        
        #Add Entry Info to Reporting Hashtable
          $htReport.add($flEntry,"1");
        
    }
 
}

#Get Current Short Date
$rptDate = Get-Date -Format d;

#Check to Number of Failed Logins About Threshold
if($Summary.Count -gt 0)
{
    #Style for HTML Table in ConvertTo-HTML
    $a = "<style>"
    $a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;}"
    $a = $a + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;text-align: center;}"
    $a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;text-align: left;}"
    $a = $a + "</style>";

    #Message Body (Sorted by Failed Login Attempts)
    $emsg = $Summary | Sort-Object {[int]$_."Failed Logins"} -descending | ConvertTo-Html -head $a | Out-String;
}
else
{
    $emsg = "<p>No Failed Logins Over the Limit to Report</p>";
}
#Settings for Email Message
$messageParameters = @{                        
                Subject = "Failed Logins Report for " + $rptDate
                Body = $emsg                       
                From = "FromAddress@mycollege.edu"                        
                To = "ToAddress@mycollege.edu"
                SmtpServer = "smtp.mycollege.edu"                       
            };                       
#Send Report Email Message 
Send-MailMessage @messageParameters –BodyAsHtml;

$fileName = "Failed_Login_Report_" + $rptDate.ToString().Replace("/","-") + ".csv";

$arrCSVFailures | Export-CSV $fileName -NoTypeInformation;