<#
	Non_AD_LDAP_Query.ps1
#>

#Var for Campus LDAP Account Password
[string]$ldapPWD = "myLongPassword";

#Load S.DS.P Assembly - Required for Use of S.DS.P in PowerShell Session
[Void][System.Reflection.assembly]::LoadWithPartialName("system.directoryservices.protocols");

#Vars for LDAP Settings
[string]$searchBase = "ou=People,dc=mycollege,dc=edu";
$searchScope = [System.DirectoryServices.Protocols.SearchScope]"Subtree";
	 
#Establishing an Authenticated Connection to the LDAP Server
$ldapIdent = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier("ldap.mycollege.edu",636,$true,$false);
$ldapCon = New-Object System.DirectoryServices.Protocols.LdapConnection($ldapIdent);
$ldapCon.Credential = New-Object System.Net.NetworkCredential("uid=mySpecialAccount,ou=accounts,dc=mycollege,dc=edu",$ldapPWD);
$ldapCon.AuthType = [System.DirectoryServices.Protocols.AuthType]::Basic;
$ldapCon.SessionOptions.ProtocolVersion = 3;
$ldapCon.SessionOptions.SecureSocketLayer = $true;
$ldapCon.Bind();

##Establishing an Anonymous Connection to the LDAP Server
#$ldapAuth = "Basic"
#$ldapIdent = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier("ldap.mycollege.edu")
#$ldapCon = New-Object System.DirectoryServices.Protocols.LdapConnection($ldapIdent,$null,$ldapAuth)
#$ldapCon.SessionOptions.ProtocolVersion = 3
#$ldapCon.SessionOptions.SecureSocketLayer = $false
#$ldapCon.Bind()

#Query Only for Specific User ID
[string]$filter = "(uid=bunnsumo)";
	 
#Send Search Request and Pull Response
$searchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest($searchBase,$filter,$searchScope); 
$searchResponse = [System.DirectoryServices.Protocols.SearchResponse]$ldapCon.SendRequest($searchRequest);
     
#Check to See If Response Returned for Kerb ID Specified
if ($searchResponse)
{
    #Loop Required for Search Responses. Tried Entries[0] However Conversion Error Occurred On One Item
    foreach ($entry in $searchResponse.Entries)
    {
	    #Create Attribute Collection
       	$srac = [System.DirectoryServices.Protocols.SearchResultAttributeCollection]$entry.Attributes
          
		   #Loop Through Attributes and Using Switch Statement Assign Returned Values to HashTable 
	       foreach ($attr in $srac.Values)
		   {
		      switch ($attr.Name.ToString()) 
              { 
               
                "uid" {write-host "uid:" $attr[0].ToString()} 
                "mail" {write-host "mail:" $attr[0].ToString()}
			    "displayName" {write-host "displayName:" $attr[0].ToString()}
			    "cn" {write-host "cn:" $attr[0].ToString()}
			    "sn" {write-host "sn:" $attr[0].ToString()}
			    "givenName" {write-host "givenName:" $attr[0].ToString()}
			    "telephoneNumber" {write-host "telephoneNumber:" $attr[0].ToString()}
			    "ou" {write-host "ou:" $attr[0].ToString()}
			    "departmentNumber" {write-host "departmentNumber:" $attr[0].ToString()}
			    "title" {write-host "title:" $attr[0].ToString()}
			    "l" {write-host "l:" $attr[0].ToString()}
			    "postalAddress" {write-host "postalAddress:" $attr[0].ToString()}
			    "postalCode" {write-host "postalCode:" $attr[0].ToString()}
			    "street" {write-host "street:" $attr[0].ToString()}
			    "st" {write-host "st:" $attr[0].ToString()}
              }
		}
    }
}
	 
Write-Host 'all done'