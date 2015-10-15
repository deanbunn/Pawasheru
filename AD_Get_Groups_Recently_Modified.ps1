<#
	AD_Get_Groups_Recently_Modified.ps1
#>

#Var for Domain to Search
$deSrcLoc = [ADSI]"LDAP://DC=mycollege,DC=edu";

#Construct a When Changed Filter. Should Look Like 20151012000000.0Z. Pacific time +7 hours
$wcUTC = (Get-Date).AddHours(+7).AddMinutes(-30).ToString("yyyyMMddHHmm") + "00.0Z";

#Set Up Directory Searcher with whenCreated Filter
$dsSearch = New-Object DirectoryServices.DirectorySearcher($deSrcLoc);
$dsSearch.filter = "(&(objectClass=group)(whenChanged>=$wcUTC))";  
$dsSearch.PageSize = 900;
$dsSearch.SearchScope = "SubTree";
$srResults = $dsSearch.Findall();

foreach($srResult in $srResults)
{
	$srResult.properties["cn"][0];
}

