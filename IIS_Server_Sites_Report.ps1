<#
   Script: IIS_Server_Sites_Report.ps1
   Version: 1.1
   Last Edited: 03/12/16
#>

#Load Required Modules
Import-Module WebAdministration;

#Array for Custom Site Objects
$arrReportSites = @();

#Var for IIS Server Name
[string]$iisServer = Hostname;

#Var for IIS App Pools Path (When Module Loaded)
[string]$iisAppPoolsPath = "IIS:\AppPools\";

#Pull IIS Sites
$iisSites = Get-Website;

#Null\Empty Check on Sites Collection
if($iisSites -ne $null -and $iisSites.Count -gt 0)
{
    
    #Loop Through Sites
    foreach($iisSite in $iisSites)
    {
       
        #Initiate Custom IIS Site Object 
        $cstIISSite = New-Object PSObject -Property (@{ServerName=""; SiteID=""; SiteName=""; SiteState=""; PhysicalPath=""; AppPoolName=""; AppPoolUserID=""; Bindings=@();});

        #Set Server Name
        $cstIISSite.ServerName = $iisServer;

        #Set Site ID
        $cstIISSite.SiteID = $iisSite.ID.ToString();

        #Set Site Name
        $cstIISSite.SiteName = $iisSite.Name;

        #Set Site Status
        $cstIISSite.SiteState = $iisSite.State;

        #Set Physical Path
        $cstIISSite.PhysicalPath = $iisSite.PhysicalPath;

        #Set Application Pool 
        #Check App Pool Name
        if([string]::IsNullOrEmpty($iisSite.applicationPool) -eq $false)
        {
            #Set App Pool Name
            $cstIISSite.AppPoolName = $iisSite.applicationPool;

            #Configure Path to the Application Pool
            [string]$appPoolFullPath = $iisAppPoolsPath + $iisSite.applicationPool;
   
            #Pull IIS App Pool
            $iisAppPool = Get-Item $appPoolFullPath;

            #Pull App Pool User Account
            if([string]::IsNullOrEmpty($iisAppPool.processModel.userName) -eq $false)
            {
                $cstIISSite.AppPoolUserID = $iisAppPool.processModel.userName;
            }
            
        }#End of App Pool Check

        #Null Check on Bindings
        if($iisSite.Bindings -ne $null)
        {
            #Loop Through Bindings
            foreach($iisBinding in $iisSite.Bindings.Collection)
            {
                
                #Initiate Custom Report Object 
                $cstIISSiteBinding = New-Object PSObject -Property (@{BindingProtocol=""; BindingIP=""; BindingPort=""; BindingHostName="";});

                #Set Binding Protocol
                $cstIISSiteBinding.BindingProtocol = $iisBinding.protocol;

                #Parse IP, Port, and Host Name
                $arrBinding = $iisBinding.bindingInformation.ToString().Split(":");

                #Set IP
                $cstIISSiteBinding.BindingIP = $arrBinding[0];

                #Set Port
                $cstIISSiteBinding.BindingPort = $arrBinding[1];

                #Check Host Name
                if($arrBinding.Count -eq 3)
                {
                    #Set Host Name
                    $cstIISSiteBinding.BindingHostName = $arrBinding[2];
                }

                #Add Custom Binding Object to Bindings Array
                $cstIISSite.Bindings += $cstIISSiteBinding;

            }#End of Bindings Foreach

        }#End of $iisSite Bindings Check

        #Add Custom Objec to Report Array
        $arrReportSites += $cstIISSite;
             
    }#End of $iisSites Foreach
    
}#End of Null\Empty Check on $iisSites


#View Custom Report 
$arrReportSites | ft;

###############################
# End of Script
###############################