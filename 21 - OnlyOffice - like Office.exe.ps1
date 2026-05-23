# ============================================================================
# FlexApp One Deployment Script - FleetCTRL
# ============================================================================
#
# ---- EDIT THESE 3 VALUES ----
#
    $appName = "21 - OnlyOffice - like Office"                 # App name (without .exe)
    $url     = "https://fa1poc.blob.core.windows.net/fa1/poc"  # Download URL (without filename)
    $options = "--system --index 999 --ctl --addtostart"       # FA1 launch options
#
# ============================================================================
#
# ---- FleetCTRL Metadata ----
# DESCRIPTION:     Deploys OnlyOffice productivity suite via FlexApp One
# TAGS:            Liquidware FlexApp
# EXECUTION MODE:  Combined
# TYPE:            app
# CATEGORY:        FlexApp Applications
# VERSION:         1.0.0.0
# UNINSTALL:       "C:\ProgramData\FlexAppOne\21 - OnlyOffice - like Office.exe" --system --stop --clean --remove
# DETECTIONRULE:   file:"%programdata%\Microsoft\Windows\Start Menu\Programs\FlexApp One\21 - OnlyOffice - like Office.lnk"

# ---- DO NOT EDIT BELOW THIS LINE ----
# ============================================================================

$runPath = "C:\ProgramData\FlexAppOne"

# ---- Uninstall mode (called by FleetCTRL with --uninstall) ----
if ($args -contains '--uninstall') {
    try { Unregister-ScheduledTask -TaskName "${appName}.exe" -Confirm:$false -EA SilentlyContinue } catch {}
    if (Test-Path "$runPath\$appName.exe") {
        Start-Process -FilePath "$runPath\$appName.exe" -ArgumentList "--system --stop --clean --remove" -Wait
    }
    if (Test-Path "$runPath\$appName.exe") { Remove-Item "$runPath\$appName.exe" -Force -EA SilentlyContinue }
    Write-Output "Uninstall complete: $appName"
    exit 0
}

# ---- Install FlexApp One service if not present ----
$instcheck = "C:\Program Files\ProfileUnity\FlexApp\ContainerService\x64\VirtFsService.exe"
if (!(Test-Path $instcheck)) {
    Write-Output "FlexApp One service not found - installing..."
    New-Item -ItemType Directory -Force -Path $runPath | Out-Null
    Import-Module BitsTransfer
    Start-BitsTransfer -Source "$url/installer.exe" -Destination "$runPath\installer.exe"
    Start-Process -FilePath "$runPath\installer.exe" -ArgumentList "--install" -NoNewWindow -Wait
    Write-Output "FlexApp One service installed."
}

# ---- Stop existing mount (releases file locks for upgrade) ----
if (Test-Path "$runPath\$appName.exe") {
    Start-Process -FilePath "$runPath\$appName.exe" -ArgumentList "--stop --clean" -Wait
    Start-Sleep -Seconds 3
}

# ---- Download and mount the FlexApp ----
New-Item -ItemType Directory -Force -Path $runPath | Out-Null
Import-Module BitsTransfer
Write-Output "Downloading $appName from $url..."
Start-BitsTransfer -Source "$url/$appName.exe" -Destination "$runPath\$appName.exe"
Start-Process -FilePath "$runPath\$appName.exe" -ArgumentList $options
Write-Output "Mounted: $appName with $options"

# ---- Schedule app to mount on reboot ----
try { Unregister-ScheduledTask -TaskName "${appName}.exe" -Confirm:$false -EA SilentlyContinue } catch {}
$taskAction = New-ScheduledTaskAction -Execute "$runPath\$appName.exe" -Argument $options
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskPrincipal = New-ScheduledTaskPrincipal -UserID "System" -LogonType ServiceAccount
$taskSettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Days 31)
Register-ScheduledTask -TaskName "${appName}.exe" -InputObject (New-ScheduledTask -Action $taskAction -Principal $taskPrincipal -Trigger $taskTrigger -Settings $taskSettings)
Write-Output "Scheduled task created: ${appName}.exe runs at startup"
