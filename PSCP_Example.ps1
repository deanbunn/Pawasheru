<#
    Script: PSCP_Example.ps1
    Author: Dean Bunn
    Date: 07-28-17
    Description: Uses PuTTY's PSCP client to pull files from a SFTP server. 
                 Make sure to first connect manually via PSCP to the SFTP server
                 to establish known host and initial PSCP settings. Convert key
                 to PuTTY's .ppk format using PuTTYgen. Automation won't work if 
                 your private key is password protected.
#>

#Regular PSCP command using key auth to copy .csv files from a remote Unix SFTP server.
#pscp -p -i C:\users\dbunn\.ssh\ucdproject.ppk ucdavis@remote.server.gov:/home/ucdavis/outgoing/*.csv C:\UCDProject

#Var for PPK Key Location
[string]$ppkKeyLoc = "C:\users\dbunn\.ssh\ucdproject.ppk";

#Var for SFTP Server and Remote Files Location
[string]$sftpSrvAndRmtFileLoc = "ucdavis@remote.server.gov:/home/ucdavis/outgoing/*.csv";

#Var Local Folder Location
[string]$lclFldr = "C:\UCDProject";

#PSCP Pull Data (using -p option to perserve file attributes)
pscp -p -i $ppkKeyLoc $sftpSrvAndRmtFileLoc $lclFldr;