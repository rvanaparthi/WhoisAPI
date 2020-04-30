# Input bindings are passed in via param block.
param($InputBlob, $TriggerMetadata, $Timer) 


# Write out the blob name and size to the information log.
Write-Host "PowerShell Blob trigger function Processed blob! Name: $($TriggerMetadata.Name) Size: $($InputBlob.Length) bytes"

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

Write-Host "$workspaceID"
Write-Host "$workspaceKey"
Write-Host "$apiusername"
Write-Host "$apipassword"

