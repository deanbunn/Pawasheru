###################################################################
# Script Name: Securely_Stored_Password_Commands.ps1
# Version: 1.0
# Author: Dean Bunn
# Last Edited: 07/02/2012
# Description: Securely Store Password Commands
###################################################################


#Create Text File with Secure String of Password
read-host -assecurestring "Please Type the Password to be Stored" | convertfrom-securestring | out-file c:\users\dbunn\desktop\thelovely.txt;

######## Following Section is How to Use It to Create a Network Credential #############
#Var for the Secure String Password
$pass = cat c:\users\dbunn\desktop\thelovely.txt | convertto-securestring;
#Create Credential to Use Against Remote Service
$mycred = New-Object System.Management.Automation.PSCredential("mydomain\dbunn",$pass);
#Display Password (If Needed for Testing)
$mycred.GetNetworkCredential();
