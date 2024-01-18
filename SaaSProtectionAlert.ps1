# API URL
$apiUrl = "https://api.datto.com/v1/saas/domains"

# Basic Auth credentials
$username = $env:DattoAPIUsername
$password = $env:DattoAPIPassword
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("${username}:${password}")))

# Invoke API request
$response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers @{
    Authorization = "Basic $($base64AuthInfo)"
}

# Hash table to store saasCustomerId and saasCustomerName
$customerData = @{}

# Process each item in the response and save required data to hash table
foreach ($item in $response) {
    $saasCustomerId = $item.saasCustomerId
    $saasCustomerName = $item.saasCustomerName
    $customerData[$saasCustomerId] = $saasCustomerName
}

# Sort the hash table by saasCustomerName
#$sortedCustomerData = $customerData.GetEnumerator() | Sort-Object Value

<#
# Display the sorted hash table
$sortedCustomerData | ForEach-Object {
    "saasCustomerId: $($_.Key), saasCustomerName: $($_.Value)"
}
#>

# New hash table to store appType and status
$appData = @{}

# New API URL
$newApiUrl = "https://api.datto.com/v1/saas/{0}/applications"

# Iterate through each saasCustomerID in the hash table
foreach ($saasCustomerId in $customerData.Keys) {
    # Construct the full API URL
    $apiUrl = $newApiUrl -f $saasCustomerId

    # Invoke API request for each saasCustomerID
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers @{
        Authorization = "Basic $($base64AuthInfo)"
    }

    # Process each item in the response and save required data to the new hash table
    foreach ($item in $response.items) {
        $customerName = $item.customerName
        foreach ($suite in $item.suites) {
            foreach ($appTypeData in $suite.appTypes) {
                foreach ($backupHistory in $appTypeData.backupHistory) {
                    if ($backupHistory.timeWindow -eq "Between1dAnd2d") {
                        $appType = $appTypeData.appType
                        $status = $backupHistory.status
                        $appData["$saasCustomerId-$customerName-$appType"] = $status
                    }
                }
            }
        }
    }
}

# Filtered hash table to store customerName, appType, and status without "Perfect" status
$filteredAppData = @{}

# Iterate through each entry in the existing hash table
foreach ($entry in $appData.GetEnumerator()) {
    $key = $entry.Key
    $status = $entry.Value

    # Filter entries without "Perfect" status
    if ($status -ne "Perfect") {
        $filteredAppData[$key] = $status
    }
}

# Display the filtered hash table without truncation
$filteredAppData | Format-Table -AutoSize

# Check if $filteredAppData is empty
if ($filteredAppData.Count -eq 0) {
    # Exit with code 0
    exit 0
} else {
    # Exit with code 1
    exit 1
}

