<#
Beginning PowerShell Session 4    
Creating Objects, Functions, and Error Handling
#>

<#
The Setting for Error Handling is Stored in the $ErrorActionPreference variable
Error Handling Options:
1) Continue = Output Error Message; Continue to Run Next Command (Default)
2) SilentlyContinue = Suppress Error Message; Continue to Run the next command
3) Stop = Halt the Execution
4) Inquire = Prompt User for Action to Perform
#>

$ErrorActionPreference = "Continue";

#Example of a Try\Catch Statement. 
#Upon an Error Occuring in the Try Statement the Catch Statement Will Process
try
{
    $x = 56;
    $y = 0;
    $z = $x/$y;
}
catch
{
    Write-Output "Something went wrong";
}

#Errors that Occur During a PowerShell Session are Stored in $error
$error

#Empty Error Messages from $error
$error.clear();

#$error Is a Collection So You Can Loop Through It
foreach($ermsg in $error)
{
    #Displays Only Error Message
    $ermsg.Exception.Message;
    #Displays Code That Caused Error
    $ermsg.InvocationInfo.Line;
    #Shows Line Number of Bad Code
    $ermsg.InvocationInfo.PositionMessage;
}

#Some Cmdlets Support an ErrorAction Statement (only for parameter data)
#These Won't Display an Error
Remove-Item nothinghere -ErrorAction "SilentlyContinue";
Stop-Process -ID 8888888 -ErrorAction "SilentlyContinue";
#This Will Due to -ID Must Be an Int
Stop-Process -ID NothingHere -ErrorAction "SilentlyContinue";

#Basic Function To Write Output
function SayHello()
{
    Write-Output "Howdy";
}

#Two Calls to the Basic Function. 
#Note that in PowerShell You Don't Use () in Function Calls
SayHello;
SayHello;

#Function with Strongly Type Variables and Default Value Set on Second Variable 
function AddNumbers([int]$num1,[int]$num2=20)
{
    return $num1 + $num2;
}

#Calling AddNumbers Function. Passed in Values are Separated by a Space
AddNumbers 4 8;

#Function That Takes a HashTable and Referenced String Variable
#When Working with Referenced Variables You Need to Set the .Value
function PassMeAround([hashtable]$htData,[ref]$status)
{
    
    $htData.Set_Item("userID","dbunn");
    $htData.Set_Item("displayName","Dean Bunn");
    $status.value = "Good to Go";
}

#Initiate The String Variable
[string]$status = "No Go";

#Initiate The HashTable
$htData = @{ 
             "userID" = $null;
             "displayName" = $null; 
           };

#Calling PassMeAround Function. Use () for Ref Variables
PassMeAround $htData ([ref]$status);

#Display Updated Values
$htData;
$status;

#Array to Hold Our Custom Shirt Objects
$closet = @();

#Custom Object Method 1
$poloShirt1 = New-Object PSObject;
$poloShirt1 | Add-Member -memberType noteProperty -name "Size" -value "XXL";
$poloShirt1 | Add-Member -memberType noteProperty -name "Color" -value "Grey";
$poloShirt1 | Add-Member -memberType noteProperty -name "Material" -value "Cotton";
$closet += $poloShirt1;

$poloShirt2 = New-Object PSObject;
$poloShirt2 | Add-Member -memberType noteProperty -name "Size" -value "XL";
$poloShirt2 | Add-Member -memberType noteProperty -name "Color" -value "Red";
$poloShirt2 | Add-Member -memberType noteProperty -name "Material" -value "Cotton";
$closet += $poloShirt2;

$poloShirt3 = New-Object PSObject;
$poloShirt3 | Add-Member -memberType noteProperty -name "Size" -value "S";
$poloShirt3 | Add-Member -memberType noteProperty -name "Color" -value "Green";
$poloShirt3 | Add-Member -memberType noteProperty -name "Material" -value "Silk";
$closet += $poloShirt3;

#Custom Object Method 2
$poloShirt4 = new-object PSObject -Property (@{ Size="M"; Color="Purple"; Material="Cotton"; });
$closet += $poloShirt4;

$poloShirt5 = new-object PSObject -Property (@{ Size="L"; Color="Pink"; Material="Polyester"; });
$closet += $poloShirt5;

$poloShirt6 = new-object PSObject -Property (@{ Size="XS"; Color="Yellow"; Material="Wool"; });
$closet += $poloShirt6;

#Custom Object Method 3            
Add-Type @'
public class Shirt
{
    public System.String Size;    
    public System.String Color;
    public System.String Material;
}
'@            
            
$poloShirt7 = New-Object Shirt;
$poloShirt7.Size = "XL";
$poloShirt7.Color = "Black";
$poloShirt7.Material = "Leather";
$closet += $poloShirt7;

$poloShirt8 = New-Object Shirt;
$poloShirt8.Size = "L";
$poloShirt8.Color = "Orange";
$poloShirt8.Material = "Cotton";
$closet += $poloShirt8;

$poloShirt9 = New-Object Shirt;
$poloShirt9.Size = "S";
$poloShirt9.Color = "Blue";
$poloShirt9.Material = "Fur";
$closet += $poloShirt9;

#View Shirt Objects
$closet;

#Array to Hold Our Custom Boxer Objects
$fighters = @();

#Custom Class with Various Object Types and a Method
Add-Type @'
public class Boxer
{
    public System.String FirstName;  
    public System.String LastName;  
    public System.DateTime LastFight;
    public System.Int32 Ranking;
    
    public System.String Punch()
    {
        return "Ka Pow!";
    }
}
'@ 

#Create Instance of Custom Class and Add to Array
$champ = New-Object Boxer;
$champ.FirstName = "Manny";
$champ.LastName = "Pacquiao";
$champ.LastFight = [System.DateTime]::Parse("05/18/2012");
$champ.Ranking = 1;
$fighters += $champ;

$contender = New-Object Boxer;
$contender.FirstName = "Dean";
$fighters += $contender;

#View Boxer Objects. Notice that Dean Has Some Interesting Default Values
$fighters;

