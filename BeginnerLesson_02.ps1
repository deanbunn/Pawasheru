#Beginning PowerShell Session 02 Training Script
#Using Variables, Conditions, and Loops
#Script Should Be Run from Desktop Folder

#Strong Typed Int Variables for Reporting Numbers
#Var for Number of PDFs
[int]$nPDF = 0;
#Var for Number of Word Documents
[int]$nWord = 0;
#Var for Number of Excel Spreadsheets
[int]$nExcel = 0;
#Var for Number of Text Files
[int]$nText = 0;

#Array for File Types We Dont Want to Compare
$exFileTypes = @("*.lnk","*.exe","*.msi","*.rdp");

#Hash Table for File Sizes
$htFileSizes = @{};

#Create System.IO.DirectoryInfo and System.IO.FileInfo Object Collection of All Desktop Items
$desktop = Get-ChildItem -Exclude $exFileTypes;

#Loop Through Each Item in Collection
foreach($di in $desktop)
{
    #Check to See If Item is Folder (We Only Want Files)
    if(!$di.PSIsContainer)
    {
        #Calculate File Size in MB
        $fSize = "{0:N3}" -f ($di.length / 1MB) + "MB";
        
        #Add File Name and Size to Hash Table
        $htFileSizes.Add($di.name,$fSize);
        
        #Example Switch Statement Based on File Extension
        switch($di.extension)
        {
            
            ".pdf" { $nPDF++ }
        
            ".doc" { $nWord++ }
            
            ".docx" { $nWord++ }
            
            ".xlsx" { $nExcel++ }
            
            ".txt" { $nText++ }
        }
        
    }#End of PSIsContainer Check

}#End of Foreach Desktop Item

#String for Report
[string]$report = "File Report Numbers PDFs:$nPDF Word:$nWord Excel:$nExcel Text:$nText";

#Blank Line
Write-Output "";

#Give User Final File Counts
Write-Output $report;

#Enumerate and Sort Our File Sizes Hash Table
$htFileSizes.GetEnumerator() | Sort-Object Name;

#Blank Line
Write-Output "";

#Example of a For Loop
for($i=0;$i -lt $desktop.Count;$i++)
{
    Write-Output $desktop[$i].fullname;
}

#Blank Line
Write-Output "";

#Example Do While Loop
$x = 0;
do
{
    #Var for File Edit Status
    $status = "";
    
    #Check to See If File Was Edited in the Last Three Days
    if($desktop[$x].LastWriteTime -gt (Get-Date).AddDays(-3))
    {
        $status = $desktop[$x].name + " - recently edited";
    }
    else
    {
        $status = $desktop[$x].name + " - over 3 days since last edit";
    }
    
    #Notify the User of File Status
    Write-Output $status;
    
    #Increment Counter for While Loop
    $x++;
}
while($x -lt $desktop.Count)

