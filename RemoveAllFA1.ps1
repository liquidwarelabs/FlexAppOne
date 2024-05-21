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

# Function to remove scheduled tasks related to FlexApps in the specified path
function Remove-FlexAppTasks {
    if (Test-Path -Path $FlexAppPath) {
        Get-ChildItem "$FlexAppPath\*.exe" -Recurse | ForEach-Object {
            $taskName = "$($_.BaseName).exe"
            try {
                Start-Process -FilePath "schtasks.exe" -ArgumentList "/Delete /tn `"$taskName`" /f" -NoNewWindow -Wait -ErrorAction SilentlyContinue
            } catch {
                # Ignore errors
            }
        }
    } else {
        Write-Output "Directory $FlexAppPath does not exist. Skipping task removal."
    }
}

# Function to stop, clean, and remove FlexApp executables in the specified path
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

# Remove scheduled tasks associated with FlexApps in the specified path
Remove-FlexAppTasks

# Clean and remove FlexApp executables in the specified path
Clean-FlexAppExecutables
