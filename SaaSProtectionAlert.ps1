# Path of report
$reportPath = "c:\CSVTest\BackupSuccessReport.csv"

# Import CSV
$reportData = Import-Csv -Path $reportPath

# Initializes the 2D array
$reportArray = @()

foreach ($row in $reportData) {
    # Initialize an inner array for each row
    $innerArray = @()

    # Iterate through columns and add each value to the inner array
    $reportData[0].PSObject.Properties | ForEach-Object {
        $innerArray += $row.$($_.Name)
    }

    # Add the inner array to the main 2D array
    $reportArray += ,$innerArray
}

$errorRow = @()

# Iterate through each row
foreach ($rowIndex in 0..($reportArray.Length - 1)) {
    foreach ($colIndex in 0..($reportArray[$rowIndex].Length - 1)) {

        if ($colIndex -eq 7) {
            $value = $reportArray[$rowIndex][$colIndex]
            if ($value -ne "Completed Successfully") {
                $errorRow += $rowIndex
            }
        }
    }
}

$isErrorRow = $false
# Write each row
foreach ($rowIndex in 0..($reportArray.Length - 1)) {
    foreach ($testIfError in $errorRow) {
        if ($testIfError -eq $rowIndex) {
            $isErrorRow = $true
        }
    }
    foreach ($colIndex in 0..($reportArray[$rowIndex].Length - 1)) {
        if ($isErrorRow) {
            if ($colIndex -eq 0) {
                $value = $reportArray[$rowIndex][$colIndex]
                Write-Output "Organization: $value"
            }
            if ($colIndex -eq 2) {
                $value = $reportArray[$rowIndex][$colIndex]
                Write-Output "Application: $value"
            }
            if ($colIndex -eq 7) {
                $value = $reportArray[$rowIndex][$colIndex]
                Write-Output "Error: $value `n"
            }
        }
    }
    $isErrorRow = $false
}




#An example of how you would write every cell of the array to output
<#
# Write each row
foreach ($rowIndex in 0..($reportArray.Length - 1)) {
    foreach ($colIndex in 0..($reportArray[$rowIndex].Length - 1)) {

        # Access the value at the current row and column
        $value = $reportArray[$rowIndex][$colIndex]

        # Display or perform operations with the value
        Write-Output "Value at [$rowIndex, $colIndex]: $value"
    }
}
#>
