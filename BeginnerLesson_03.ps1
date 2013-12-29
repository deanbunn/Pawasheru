################################################
# Beginning PowerShell Session 3 Commands
# Working with the Pipeline, Input, and Outputs
################################################

##### Pipeline ########################################

#Using Out-File to Get Resource Info on the Pipeline
Get-Help About_pipeline | Out-File about_pipeline.txt

#Get All Process and Then Sort by Display Name
Get-Process | Sort-Object ProcessName -descending

#Stop All Notepad Process and Log Process Collection Before Stopping
Get-Process notepad | Tee-Object -file Notepad_Processes.txt | Stop-Process

#Command to Find If CmdLet Allows for Piping (Check Accept Pipeline Property Under Parameters) 
Get-Help cmdletName -full | more 

#Get All Services That Are Running Then Only Show the Display Name
Get-Service | Where { $_.Status -eq "Running" } | ForEach-Object { $_.DisplayName }

# Quick Way to Report on File Types in a Folder
Get-ChildItem | Group-Object -property extension

##### Outputs #########################################

#To Get All the Format Object Commands
Get-Command -verb format

#Get All Processes in a GUI Gridview
Get-Process | Out-GridView

#Output Sent to a File
Get-Service | Out-File Services.txt

#Service List Sent to Your Default Printer
Get-Service | Out-Printer 

#Running Service List With Only a Few Columns Exported to CSV
Get-Service | Where { $_.Status -eq "Running" } | Select-Object Name,DisplayName,Status,CanStop | Sort-Object DisplayName | Export-Csv tester.csv -NoTypeInformation

#### Inputs ############################

#Prompt User for Info
$requiredData = Read-Host -prompt "Enter Required Data"

#Create String Array From a Text File 
$servers = Get-Content Servers.txt

#Import Data a CSV File and Use a Specific Column From It
Import-Csv DeptUsers.csv | Foreach { $_.DisplayName }

