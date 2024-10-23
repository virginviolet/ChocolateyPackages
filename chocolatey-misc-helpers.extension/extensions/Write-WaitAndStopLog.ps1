$ErrorActionPreference = 'Stop'

function Write-WaitAndStopLog {
    Write-Debug "Write-WaitAndStopLog started."
    $currentPath = (Get-Location).Path
    $reportPath = Join-Path $currentPath "WaitAndStop.log"
    Write-Debug "Looking for '$reportPath'..."
    $exists = Test-Path $reportPath -PathType Leaf
    if ($exists) {
        Write-Debug "WaitAndStop log found."
        Write-Debug "Writing WaitAndStop report."
        Get-Content $reportPath
        Write-Debug "Removing WaitAndStop log..."
        Remove-Item $reportPath
        Write-Debug "WaitAndStop log removed."
    }
    else {
        # Write-Debug "Nothing to report."
        Write-Debug "WaitAndStop log file not found."
    }
}

###### Debug start
# Write-WaitAndStopLog