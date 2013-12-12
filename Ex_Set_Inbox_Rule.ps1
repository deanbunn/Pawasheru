<#
Script Name: Ex_Set_Inbox_Rule.ps1
Version: 1.0
Author: Dean Bunn
Last Edited: 11/09/2012
Description: Adds Spam Score Rule to Mailboxes
Notes: I was tasked with creating a PowerShell script that would create a server side spam rule for all mailboxes in an 2010 environment. 
       Using the Get-InboxRule and New-InboxRule cmdlets I was easily able to create a script that looked to see if the rule didn't 
       already exist on the mailbox before it created it. The spam rule in this environment looks for a specific text in the header 
       of the message. If it finds the text it will move the item to the Junk E-mail Folder.
       ****Please be warned that if you use the New-InboxRule cmdlet on a mailbox it will remove any client side rules****
#>

#Pull Collection of All Mailboxes 
$mbxs = Get-Mailbox -resultsize unlimited;

foreach($mbx in $mbxs)
{

    #Null Check on Primary SMTP Address
    if($mbx.PrimarySmtpAddress)
    {
        #Vars for New Inbox Rule
        [string]$primSMTP = $mbx.PrimarySmtpAddress.ToString();
        [string]$junkFolder = $mbx.PrimarySmtpAddress.ToString() + ":\Junk E-Mail";
        [string]$xscore = "X-Spam-Score: ****";
        [boolean]$existingRule = $false;
        
        #Retrieve Mailbox Rules
        $inboxRules = Get-InboxRule -mailbox $mbx.PrimarySmtpAddress.ToString();
        
        #Check to See If Any Rules Exist on Mailbox
        #If So Check for the SpamRule -ne $null -and $inboxRules.Count -gt 0
        if($inboxRules)
        {
             foreach($ibxr in $inboxRules)
            {
                if($ibxr.Name.ToString().Trim() -eq "SpamRule")
                {
                    $existingRule = $true;
                }
            }
            
        }
        
        #If Rule Doesn't Exist Create It
        if($existingRule -eq $false)
        {
            New-InboxRule -mailbox $primSMTP -Name "SpamRule" -Confirm:$False -MoveToFolder 
           $junkFolder -HeaderContainsWords @{add=$xscore} -StopProcessingRules $true;
        }
        
    }#End of Primary Address Check
    
}#End of Foreach Mailbox
