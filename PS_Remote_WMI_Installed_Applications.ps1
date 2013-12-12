#########################################################
# Script Name: PS_Remote_WMI_Installed_Applications.ps1
# Version: 1.0
# Author: Dean Bunn
# Description: Using WMI Remotely Queries
#               Systems for Installed Software
#########################################################

#Array for Reporting Installed Software
$installedApps = @();

#Array for Registry Paths to Installed Apps
$appRegPaths = @("Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
                 "Software\Microsoft\Windows\CurrentVersion\Uninstall");

#Array of System Names to Run Against
$computers = @("SERVER01","SERVER02","SERVER03");

foreach($computer in $computers)
{
    #Ping System First
    if(Test-Connection -ComputerName $computer -Quiet)
    {
        #Connect to WMI Registry Class
        $uReg = [wmiclass]"\\$computer\root\default:StdRegProv";
                          
        foreach($regPath in $appRegPaths)
        {
            #Pull the Application Registry Keys 
            $iAppKeys = $uReg.EnumKey(2147483650,$regPath);
    
            #Null Check on Application Registry Keys
            if($iAppKeys)
            {
                #Loop Through Each Application Key
                foreach($appKey in $iAppKeys.sNames)
                {
                    #Construct Key Path
                    $keyPath = $regPath + "\" + $appKey.ToString();
                    
                    #Pull the Key DisplayName String Value
                    $keyDisplayName = $uReg.GetStringValue(2147483650,$keyPath,"DisplayName");
                    if(![string]::IsNullOrEmpty($keyDisplayName.sValue))
                    {
                        #Local Vars Used for Reporting
                        [string]$displayName = $keyDisplayName.sValue.ToString();
                        [string]$displayVersion = "";
                    
                        #Pull the Key DisplayVersion String Value
                        $keyDisplayVersion = $uReg.GetStringValue(2147483650,$keyPath,"DisplayVersion");
                        if(![string]::IsNullOrEmpty($keyDisplayVersion.sValue))
                        {
                            $displayVersion = $keyDisplayVersion.sValue.ToString();
                        }
                
                        #Create Custom PSObject and Add to Reporting Array
                        $app = New-Object PSObject;
                        $app | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $computer;
                        $app | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $displayName;
                        $app | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $displayVersion;
                          $installedApps += $app;
                        
                    }#End of Null\Empty Check on DisplayName String Value
                    
                }#End of Foreach $iAppKeys
            
            }#End of Null Check on $iAppKeys
        
        }#End of Foreach Reg Path
    
    }#End of Test-Connection

}#End of Foreach Computer

$installedApps | Sort-Object ComputerName,DisplayName | Format-Table -AutoSize;