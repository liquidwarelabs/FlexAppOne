#description: Deletes all FlexApps within ProgramData\FlexAppOne and Scheduled Tasks
#tags: Liquidware FlexApp
#execution mode: Combined

<#
  Notes:
  This FlexApp One is hosted on a Liquidware blob location.
#>

$FlexAppPath = "C:\ProgramData\FlexAppOne"
$options = "--system --stop --clean --remove"

# Ensure silent progress preference
$ProgressPreference = 'SilentlyContinue'

# Function to remove scheduled tasks related to FlexApps
function Remove-FlexAppTasks {
    Get-ScheduledTask | Where-Object {$_.TaskName -like "*FA1*" -or $_.TaskName -like "*.exe"} | ForEach-Object {
        try {
            $taskName = $_.TaskName
            Start-Process -FilePath "schtasks.exe" -ArgumentList "/Delete /tn `"$taskName`" /f" -NoNewWindow -Wait -ErrorAction SilentlyContinue
        } catch {
            # Ignore errors
        }
    }
}

# Function to stop, clean, and remove FlexApp executables
function Clean-FlexAppExecutables {
    if (Test-Path -Path $FlexAppPath) {
        Get-ChildItem "$FlexAppPath\*.exe" -Recurse | ForEach-Object {
            if ($_.BaseName -ne "installer") {
                if (Test-Path $_.FullName) {
                    try {
                        Start-Process -FilePath $_.FullName -ArgumentList "$options" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                        Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
                    } catch {
                        # Ignore errors
                    }
                }
            }
        }
    } else {
        Write-Output "Directory $FlexAppPath does not exist. Skipping executable cleanup."
    }
}

# Remove scheduled tasks
Remove-FlexAppTasks

# Clean and remove FlexApp executables
Clean-FlexAppExecutables
