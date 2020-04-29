# Input bindings are passed in via param block.
param($InputBlob, $TriggerMetadata, $Timer) 


# Write out the blob name and size to the information log.
Write-Host "PowerShell Blob trigger function Processed blob! Name: $($TriggerMetadata.Name) Size: $($InputBlob.Length) bytes"

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}



# Replace with your Primary Key
$sharedKey = "$env:workspacekey"

Write-Host $sharedkey

# Replace with your Primary Key
$apipassword = "$env:password"

Write-Host $apipassword

# You can use an optional field to specify the timestamp from the data. If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
$TimeStampField = Get-Date
