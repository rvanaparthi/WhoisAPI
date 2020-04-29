# Input bindings are passed in via param block.
param($InputBlob, $TriggerMetadata, $Timer) 


# Write out the blob name and size to the information log.
Write-Host "PowerShell Blob trigger function Processed blob! Name: $($TriggerMetadata.Name) Size: $($InputBlob.Length) bytes"

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}




# Replace with your Workspace ID
$customerId = "$env:workspaceid"  

# Replace with your Primary Key
$sharedKey = "$env:workspacekey"

# Specify the name of the record type that you'll be creating
$LogType = "DomainSearchWHOIS"

# You can use an optional field to specify the timestamp from the data. If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
$TimeStampField = Get-Date

$content = $InputBlob

$content | Out-File "Domains.csv"

$content.GetType();

$csvPath = 'Domains.csv'
$csvData = Get-Content -Path $csvPath | Select-Object -Skip 1

foreach ($domain in $csvData ) {
try{

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $env:apibearertoken")
        $headers.Add("Content-Type", "application/json")
        $URI = "https://investigate.api.umbrella.com/whois/$domain"
        $responses = Invoke-Restmethod  -uri $Uri -Method 'GET' -Headers $headers 
        $json = $responses | Select-Object -Property registrantCountry, zoneContactEmail, created, domainName, expires, nameServers, auditUpdatedDate, timeOfLatestRealtimeCheck, registrantName, updated | ConvertTo-Json -Depth 3 
        
 

        # Create the function to create the authorization signature
        Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
        {
            $xHeaders = "x-ms-date:" + $date
            $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

            $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
            $keyBytes = [Convert]::FromBase64String($sharedKey)

            $sha256 = New-Object System.Security.Cryptography.HMACSHA256
            $sha256.Key = $keyBytes
            $calculatedHash = $sha256.ComputeHash($bytesToHash)
            $encodedHash = [Convert]::ToBase64String($calculatedHash)
            $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
            return $authorization
        }


        # Create the function to create and post the request
        Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType)
        {
            $method = "POST"
            $contentType = "application/json"
            $resource = "/api/logs"
            $rfc1123date = [DateTime]::UtcNow.ToString("r")
            $contentLength = $body.Length
            $signature = Build-Signature `
                -customerId $customerId `
                -sharedKey $sharedKey `
                -date $rfc1123date `
                -contentLength $contentLength `
                -method $method `
                -contentType $contentType `
                -resource $resource
            $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"
            Write-Output $uri
            $headers = @{
                "Authorization" = $signature;
                "Log-Type" = $logType;
                "x-ms-date" = $rfc1123date;
                "time-generated-field" = $TimeStampField;
            }

            Write-Host $Domain
            $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
            Write-Output -Message ('Post Function return Code, site is ok '  + $response.StatusCode)  
            return $response.StatusCode
}
            Write-Output $URI
            Write-Output $domain
            # Submit the data to the API endpoint
            Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType


}catch{
            
            # Dig into the exception to get the Response details.
            # Note that value__ is not a typo.
            Write-Host "$domain" ":" "The site may be down, Please check!" ":" "StatusCode:" $_.Exception.Response.StatusCode.value__ 
            Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
            continue;
    }
}


# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME:  $(Get-Date -format 'u'):"