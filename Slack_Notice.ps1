<#
	Slack_Notice.ps1
#>

#Webhook URL 
[string]$uri = "https://hooks.slack.com/services/XXXXXXX/XXXXXXXX/XXXXXXXXXXXXX";

#Custom Object for Slack Notice
$cstSlackNotice = new-object PSObject -Property (@{ channel=""; username=""; text=""; icon_emoji=""; });

#Set Values (If Not Done When Initiating Custom Object)
$cstSlackNotice.channel = "#mychannelname";
$cstSlackNotice.username = "MyDevBot";
$cstSlackNotice.text = "This notice posted by PowerShell script";
$cstSlackNotice.icon_emoji = ":panda_face:";

#Convert Slack Notice to JSON
$jsonSlack = $cstSlackNotice | ConvertTo-Json;

#Post Slack Notice
Invoke-WebRequest -uri $uri -Method POST -Body $jsonSlack