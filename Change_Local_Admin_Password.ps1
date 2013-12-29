#############################################################################
# Script Name: Change_Local_Admin_Password.ps1
# Version: 1.0
# Author: Dean Bunn
# Last Edited: 11/28/2011
# Description: Changes Local Administrator Account Password on Remote Systems
#############################################################################

#Write Out Blank Line (Easier on the Eyes)
Write-Host ""

#Prompt User for New Password (Stored as Secure String)
$sPwd = Read-Host -assecurestring "Please Enter The New Local Admin Password"

#Create PSCredential with Secure String Password (Needed for Secure String Conversion)
$tempCred = New-Object System.Management.Automation.PSCredential("nada",$sPwd)

#Create Network Credential Using The PSCredential Object
$nc = $tempCred.GetNetworkCredential()

#Pull Plain Text Password from Network Credential Object
$uPwd = $nc.Password.ToString()

Write-Host "" #Same Eyes

#Array of Computer Names that Need Local Admin Password Changed
$computers = @("dept-wrks1.mycollege.edu","dept-wrks2.mycollege.edu","honeybunn.mycollege.edu")

foreach($computer in $computers)
{

    #Ping Computer Before Attempting Password Change 
    if (test-connection -computername $computer -quiet) 
    {
         
        try
        {
    
            #Var for WinNT Path to Local Administrator Account on Remote System
            $WinNTPath = "WinNT://" + $computer + "/Administrator,User"
        
            #Attach to Local Admin Account
            $lAdmin = [ADSI]$WinNTPath
        
            #Set Local Admin Password
            $lAdmin.setpassword($uPwd)
            
            Write-Host "Successfully Set Password on " $computer
            
        }
        catch
        {
            #Notify Admin of Failure
            Write-Host "Error When Setting Password on " $computer
        }
       
    }
    else
    {
        #Notify Admin of Failed Ping
        Write-Host "Ping Failed to" $computer
    }

}