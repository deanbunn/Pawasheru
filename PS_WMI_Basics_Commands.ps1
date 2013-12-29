############################################################
# WMI PowerShell Commands
############################################################

#Use -ComputerName Option with Hostname, FQDN, or IP Address in Command for Remote Systems
#For Example to Get the BIOS Settings On a System Called DeanTestServer
Get-WmiObject -Query "SELECT * FROM Win32_BIOS" -ComputerName "DeanTestServer"
#Or Use the IP Address
Get-WmiObject -Query "SELECT * FROM Win32_BIOS" -ComputerName "192.168.2.25"

#Get-WMIObject Can Use A WOL Query, Filter, or PowerShell Where Statement to Limit Results
#For Example the Following Three Commands Have the Same Result
Get-WmiObject -Class Win32_Share | Where-Object { $_.Name -eq "C$" }
Get-WmiObject -Class Win32_Share -Filter "Name='C$'"
Get-WmiObject -Query "SELECT * FROM Win32_Share WHERE Name='C$'"

#Get All Win_32 Classes in the CIMV2 Namespace
Get-WmiObject -Namespace "root\cimv2" -List | Where-Object { $_.Name -like "Win32_*" } | Select-Object Name | Sort-Object Name | Out-File WMI_CIMV2_Classes.txt

#Get All Properties and Methods for the WMI Class
Get-WmiObject Win32_Volume | Get-Member

#Get Basic System Information
Get-WmiObject -Query "SELECT * FROM Win32_ComputerSystem"

#Get Local Accounts and Groups on a System
Get-WmiObject -Query "SELECT * FROM Win32_Account" | Select-Object Name,SID | Sort-Object Name

#Get Disk Information (Model and Size)
Get-WmiObject -Query "SELECT * FROM Win32_DiskDrive"

#Get Processor Information
Get-WmiObject -Query "SELECT * FROM Win32_Processor" | Select-Object Name,Description,NumberOfCores | Sort-Object Name 

#Get Operating System Info
Get-WmiObject -Query "SELECT * FROM Win32_OperatingSystem"

#Get MAC Addresses of All Network Adapters
Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapter WHERE MACAddress IS NOT NULL" | Select-Object Name,MACAddress | Sort-Object Name;

#Get All Assigned IPs 
Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapterConfiguration" | Where-Object { $_.IPAddress -ne $null} | Select-Object Description,IPAddress;

#List Number of Memory Slots on a System
Write-Output ("Number of Memory Slots: " + (Get-WmiObject -Query "SELECT * FROM win32_PhysicalMemoryArray").MemoryDevices);

#Retrieve Memory Slot Allocations
Get-WMIObject -Query "SELECT * FROM Win32_PhysicalMemory" | ForEach-Object { Write-Output ($_.DeviceLocator.ToString() + " " + ($_.Capacity/1GB) + "GB") };

#Retrieve Disk Volume Sizes (Including Mount Points, Excluding Pass Through Drives)
$sysVolumes = Get-WmiObject –Query "Select * FROM Win32_Volume WHERE DriveType=3 AND NOT Name LIKE '%?%'" | Sort-Object Name;
foreach($sv in $sysVolumes)
{
    #Var for Volume Size
    $vSize = "{0:N2}" -f ($sv.Capacity/1GB);
    #Var for Free Space 
    $vFS = "{0:N2}" -f ($sv.FreeSpace/1GB);
    #Var for Percentage Free Space
    $vPF = "{0:N2}" -f (($sv.FreeSpace/$sv.Capacity)*100);
    #Var for Drive Letter
    $vLetter = $sv.Name.ToString().TrimEnd("\");
    $VolumeStatus = "$vLetter | Size(GB): $vSize | Free Space(GB): $vFS | Percentage Free: $vPF"; 
    Write-Output $VolumeStatus;
}
