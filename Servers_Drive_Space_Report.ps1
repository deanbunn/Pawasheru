<#
    Servers_Drive_Space_Report.ps1
#>

#Error Handling
$erroractionpreference = "SilentlyContinue";

#Function for Email Notices
function uEmailNotice([string]$msgBody,[string]$msgSubject)
{
    #Variable for Email FROM Address
    $mFrom = "fromAddress@mycollege.edu";
    #Variable for EMail TO Address
    $mTo = "toAddress@mycollege.edu";
    #Variable for SMTP Server
    $smtp = "smtpServer.mycollege.edu";

    #Settings for Email Message
    $messageParameters = @{                        
                            Subject = $msgSubject
                            Body = $msgBody                       
                            From = $mFrom                        
                            To = $mTo                        
                            SmtpServer = $smtp                       
                           };                        
    #Send Report Email Message 
    Send-MailMessage @messageParameters –BodyAsHtml;
}

#Var for Disk Percentage to Check
$percentCheck = 12;

#Array for Server Names
$Servers = @(
              "server1.mycollege.edu",
              "server2.mycollege.edu",
              "server3.mycollege.edu",
              "server4.mycollege.edu"
             );



#Array for Systems with Low Free Disk Percentages
$arLFDP = @();

#Var for HTML Message Body
$msgBody = "<html>
            <body>
            <h3>Servers Disk Space Report</h3>";
            
#Var for HTML All Server Table Info
$sTableInfo    = "<table border=""0"" cellpadding=""5"" cellspacing=""2"" style=""font-size:8pt;font-family:Arial,sans-serif"">
               <tr bgcolor=""#000099"">
                <td><strong><font color=""#ffffff"">Server</font></strong></td>
                <td><strong><font color=""#ffffff"">Drive</font></strong></td>
                <td><strong><font color=""#ffffff"">Size (GBs)</font></strong></td>
                <td><strong><font color=""#ffffff"">Free Space (GBs)</font></strong></td>
                <td><strong><font color=""#ffffff"">% Free</font></strong></td>
               </tr>";
               
#Loop Through All Servers
foreach($server in $Servers)
{
    #Pull Server Name from FQDN
    $sName = ($server.ToString().Split("."))[0].ToString().ToUpper();
    
    #Compose Table Row for Server Name
    $sTableInfo += "<tr bgcolor=""#dddddd"" cellspacing=""0"">
                    <td>$sName</td>
                     <td colspan=""4""></td> 
                     </tr>";
    
    #Ping Computer Before Attempting Remote WMI 
      if(test-connection -computername $server -quiet) 
      {
        #Make WMI Call to Remote Server
        $sysDrives = Get-WmiObject –Query "Select * FROM Win32_LogicalDisk WHERE DriveType=3" -ComputerName $server;
        
        #Null Check on $sysDrives  
        if($sysDrives)
        {
            #Loop Through Each Logical Disk on Server
            foreach($drive in $sysDrives)
            {
                #Var for Percentage Free Space
                $dPF = "{0:N2}" -f (($drive.FreeSpace / $drive.Size) * 100);
                #Var for Free Space
                $dFS = "{0:N2}" -f ($drive.FreeSpace / 1GB);
                #Var for Disk Size
                $dSize = "{0:N2}" -f ($drive.Size / 1GB);
                #Var for Drive Letter
                $dLetter = $drive.DeviceID.ToString();
                #Double for Percentage Free Comparison
                $freePercent = [double]$dPF.ToString();
                
                #Check to See If Drive Percentage Free Is Greater Than or Equal to Set Alert Amount
                if($freePercent -ge $percentCheck)
                {
                    #Add Disk Info 
                    $sTableInfo += "<tr>
                                    <td></td>
                                    <td>$dLetter</td>
                                     <td>$dSize</td>
                                     <td>$dFS</td>
                                     <td>$dPF</td>
                                     </tr>";
                    
                }
                else
                {    
                    #Add Disk Info with Alert Formatting
                    $sTableInfo += "<tr>
                                    <td></td>
                                    <td><font color=""#ff0000"">$dLetter</font></td>
                                     <td><font color=""#ff0000"">$dSize</font></td>
                                     <td><font color=""#ff0000"">$dFS</font></td>
                                     <td><font color=""#ff0000"">$dPF</font></td>
                                     </tr>";
                    
                    #Create PS Object for Low Disk Space Alert
                       $uEntry = new-Object PSObject;
                       $uEntry | add-Member -memberType noteProperty -name "Server" -Value $sName.ToString().ToUpper();
                       $uEntry | add-Member -memberType noteProperty -name "Drive" -Value $dLetter.ToString();
                       $uEntry | add-Member -memberType noteProperty -name "Percentage" -Value $dPF.ToString();
                       #Add Entry to Summary Array
                       $arLFDP += $uEntry;
                    
                }#End of Percentage Free Check
                                          
            }#End of Foreach Drive
            
        }
        else
        {
            #RPC Not Avaialable
            $sTableInfo += "<tr>
                            <td></td>
                             <td colspan=""4""><font color=""#ff0000"">RPC Not Available</font></td> 
                           </tr>";
            
        }#End of $sysDrives Null Check
        
    }
    else
    {
        #Server Not Pingable
        $sTableInfo += "<tr>
                        <td></td>
                         <td colspan=""4""><font color=""#ff0000"">Ping Failed</font></td> 
                        </tr>";
        
    }#End of Ping Test
    
    #Add Blank Line After Server Info Placed (Readability)
    $sTableInfo += "<tr>
                    <td colspan=""5""></td> 
                    </tr>";
}

#Write Alerts to HTML Message Body If Any
if($arLFDP.Count -gt 0)
{
    $msgBody += "<strong>Servers with Drives Less than $percentCheck% Free</strong><br />
                <table border=""0"" cellpadding=""5"" cellspacing=""2"" style=""font-size:8pt;font-family:Arial,sans-serif"">
                   <tr bgcolor=""#ff0000"">
                    <td><strong><font color=""#ffffff"">Server</font></strong></td>
                    <td><strong><font color=""#ffffff"">Drive</font></strong></td>
                    <td><strong><font color=""#ffffff"">% Free</font></strong></td>
                 </tr>";

    foreach($alert in $arLFDP)
    {
        $msgBody += "<tr><td>" + $alert.Server.ToString() + "</td><td>" + $alert.Drive.ToString() + "</td><td>" + $alert.Percentage.ToString() + "</td></tr>";
    }

    $msgBody += "</table>
                 <br />";
}

#Title All Servers Table
$msgBody +=  "<strong>All Servers</strong><br />";

#Add Servers Table Info to Message Body
$msgBody += $sTableInfo;

#Close HTML Table and Message
$msgBody += "</table>
            </body>
            </html>";
            
#Get Current Short Date
$rptDate = Get-Date -Format d;

#Format Message Subject
$msgSubject = "Servers Disk Space Report for " + $rptDate;

#Email Report
uEmailNotice $msgBody $msgSubject;