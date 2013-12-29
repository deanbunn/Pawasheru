#Get Version of PowerShell Running on System
$PSVersionTable

#Start a Transcript File
Start-Transcript C:\Users\userID\desktop\MyTranscript.txt
#Or for the File to be Placed in the Current Directory
Start-Transcript "MyTranscript.txt"
#Or for the Default Location (..\Do C:\Users\userID\Documents\PowerShell_transcript.NNNNNNNNNNN.txt
Start-Transcript

#To Stop the Transcript from Recording Commands and Output
Stop-Transcript

#Set the Script Execution Policy for Current User 
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

#Get All Currently Loaded PowerShell Snapins
Get-PSSnapin

#Get All Commands in a Specific PowerShell Snapin
Get-Command -pssnapin NameOfPSSnapin #(e.g. Microsoft.PowerShell.Security)

#Get All PowerShell Modules Available on System
Get-Module -ListAvailable

#Import Module in Current PowerShell Session
Import-Module NameOfModule #(e.g. ActiveDirectory)

#Get All Commands in a Module (Should Only Be Used After Importing)
Get-Command -Module NameOfModule

#Get All Currently Loaded Cmdlets
Get-Command -CommandType Cmdlet

#Online Help for a Cmdlet
Get-Help NameOfCmdlet -Online

#Find .NET Object Used in Cmdlet
NameOfCmdlet | Get-Member
