# ============================================================================
# Remove All FlexApp One Apps — FleetCTRL
# ============================================================================
#
# ---- FleetCTRL Metadata ----
# DESCRIPTION:     Removes ALL FlexApp One apps, scheduled tasks, and downloaded files
# TAGS:            Liquidware FlexApp
# EXECUTION MODE:  Combined
# TYPE:            utility_remove_all
# CATEGORY:        FlexApp Utilities
# VERSION:         1.0.0.0
#
# ---- DO NOT EDIT BELOW THIS LINE ----
# ============================================================================

$FlexAppPath = "C:\ProgramData\FlexAppOne"
$options = "--system --stop --clean --remove"

$ProgressPreference = 'SilentlyContinue'

# ---- Remove scheduled tasks for all FlexApps ----
if (Test-Path $FlexAppPath) {
    Get-ChildItem "$FlexAppPath\*.exe" -Recurse | ForEach-Object {
        $taskName = "$($_.BaseName).exe"
        try {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
            Write-Output "Removed task: $taskName"
        } catch {
            Write-Output "No task found: $taskName"
        }
    }
} else {
    Write-Output "Directory $FlexAppPath does not exist. Skipping task removal."
}

# ---- Stop, clean, and remove all FlexApp EXEs ----
if (Test-Path $FlexAppPath) {
    Get-ChildItem "$FlexAppPath\*.exe" -Recurse | ForEach-Object {
        $appExe = $_.FullName
        $appName = $_.BaseName
        Write-Output "Removing: $appName"
        try {
            Start-Process -FilePath $appExe -ArgumentList $options -NoNewWindow -Wait -ErrorAction SilentlyContinue
        } catch {
            Write-Output "  Could not run $appName with $options"
        }
        Remove-Item $appExe -Force -ErrorAction SilentlyContinue
        Write-Output "  Removed: $appName"
    }
} else {
    Write-Output "No FlexApp One apps found at $FlexAppPath"
}

Write-Output "All FlexApp One apps removed."
