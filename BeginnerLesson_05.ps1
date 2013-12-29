#Beginning PowerShell Session 5: Working with the File System

#Get List of All "Item" Cmdlets
Get-Command -noun item | Select-Object Name | Sort-Object Name | Out-File Item_Commands.txt

<#
Clear-Item                                                                                                             
Copy-Item                                                                                                              
Get-Item                                                                                                               
Invoke-Item                                                                                                            
Move-Item                                                                                                              
New-Item                                                                                                               
Remove-Item                                                                                                            
Rename-Item                                                                                                            
Set-Item 
#>

#Get the Path of Current Operating Directory
(get-location).path

#Check to See If a Directory or File Exists
Test-Path -Path c:\wutang\clan.txt

#Get List of All "Content" Cmdlets
Get-Command -Noun content

<#
Add-Content
Clear-Content
Get-Content
Set-Content
#>

#Search for All Text Files on System Drive
Get-Childitem -Path c:\ -Filter *.txt -Recurse;

#Create a Folder
New-Item Dean_Scripts -ItemType Directory 

#Create a Text File 
New-Item .\Dean_Scripts\first_script.ps1 -ItemType File;

#Add Content to a File
Add-Content -Path .\Dean_Scripts\first_script.ps1 -Value "Get-Service";

#Move or Rename a File
Move-Item .\Dean_Scripts_New\Friday.txt .\Dean_Scripts\Friday.txt;

#Get the Owner of a Directory or File
(Get-Acl -Path c:\Intel\Logs).Owner 

#List the NTFS Permissions of a File or Folder
(Get-Acl -Path $env:programfiles).Access

#Get the First 10 Items in the Windows Update Log
Get-Content $env:windir\windowsupdate.log | Select-Object -first 10

#Display the Lines of the Windows Update Log that Have "Added Update" in Them
Get-Content $env:windir\windowsupdate.log | Select-String "Added update"

