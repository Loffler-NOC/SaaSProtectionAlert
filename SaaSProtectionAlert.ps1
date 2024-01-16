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

# Access the value from C3 (third row, third column)
$valueFromC3 = $reportArray[2][2]

# Display the value
Write-Output "Value from C3: $valueFromC3"

$errorRow = @()

# Iterate through each row
foreach ($rowIndex in 0..($reportArray.Length - 1)) {
    foreach ($colIndex in 0..($reportArray[$rowIndex].Length - 1)) {

        if ($colIndex -eq 7) {
            if ($reportArray[$rowIndex][$colIndex] -eq "Success with exception") {
                $errorRow += $rowIndex
            }
        }
    }
}

# Write each row
foreach ($rowIndex in 0..($reportArray.Length - 1)) {
    foreach ($colIndex in 0..($reportArray[$rowIndex].Length - 1)) {

        # Access the value at the current row and column
        $value = $reportArray[$rowIndex][$colIndex]

        # Display or perform operations with the value
        Write-Output "Value at [$rowIndex, $colIndex]: $value"
    }
}
