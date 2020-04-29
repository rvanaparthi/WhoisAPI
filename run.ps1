# Replace with your Primary Key
$sharedKey = "$env:workspacekey"

Write-Host $sharedkey

# Replace with your Primary Key
$apipassword = "$env:password"

Write-Host $apipassword

# You can use an optional field to specify the timestamp from the data. If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
$TimeStampField = Get-Date
