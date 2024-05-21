# 21 - OnlyOffice - like Office via Liquidware FlexApp One.
# There are many ways to centrally 'stream' or 'deploy' FlexApp / FlexApp One.
# Unregister Error is normal if the ScheduledTask does not already exist.

#description: 21 - OnlyOffice - like Office via Liquidware FlexApp One. There are many ways to centrally 'stream' or 'deploy' FlexApp / FlexApp One.
#tags: Liquidware FlexApp
#execution mode: Combined

# Only edit the following section                          #documentation
# For appName, do not add .exe                             #documentation
# appName and url parameters are usually Case Sensitive    #documentation
# You can test the download by placing url/appName.exe in your browser #documentation

#
$appName = "21 - OnlyOffice - like Office"                 #parameter without the .exe
$installer = "installer"                                   #parameter without the .exe
$instoptions = "--install"                                 #parameter
$instcheck = "C:\Program Files\ProfileUnity\FlexApp\ContainerService\x64\VirtFsService.exe"  #parameter
$url     = "https://fa1poc.blob.core.windows.net/fa1/poc"  #parameter
$options = "--system --index 999 --ctl --addtostart"       #parameter
$runPath = "C:\ProgramData\FlexAppOne"                     #parameter
# Normally you do not edit past here

# Create FlexApp One download location - runPath
If (!(Test-Path -PathType Container $runPath)) {
    New-Item -ItemType Directory -Path $runPath
}

# Check if VirtFsService.exe exists
If (!(Test-Path -Path $instcheck)) {
    Write-Output "File not found: $instcheck. Downloading and installing $installer."

    # Download installer
    Write-Output "Downloading latest version of '$installer' from $url"
    $startTime = Get-Date

    # BitsTransfer module
    Import-Module BitsTransfer
    Start-BitsTransfer -Source "$url/$installer.exe" -Destination "$runPath\$installer.exe"
    Write-Output "Time taken: $((Get-Date).Subtract($startTime).Seconds) second(s)"
    Write-Output "Installer downloaded."

    # Run installer with options
    Write-Output "Running installer."
    Start-Process -FilePath "$runPath\$installer.exe" -ArgumentList "$instoptions" -NoNewWindow -Wait
    Write-Output "Installer $installer.exe was run with $instoptions."
} else {
    Write-Output "File already exists: $instcheck"
}

# Download the FlexApp
Write-Output "Downloading latest version of '$appName' from $url"
$startTime = Get-Date

# BitsTransfer module
Import-Module BitsTransfer
Start-BitsTransfer -Source "$url/$appName.exe" -Destination "$runPath\$appName.exe"
Write-Output "Time taken: $((Get-Date).Subtract($startTime).Seconds) second(s)"
Write-Output "New application downloaded."

# Stop Clean the app before running
Write-Output "Stop Clean app."
Start-Process -FilePath "$runPath\$appName.exe" -ArgumentList "--stop --clean" -Wait
Write-Output "FlexApp One $appName.exe, was run with --stop --clean."

# Run FlexApp with Options
Write-Output "Loading new app."
Start-Process -FilePath "$runPath\$appName.exe" -ArgumentList "$options"
Write-Output "FlexApp One $appName.exe, was run with $options."

# Remove existing scheduled task with the same name
try {
    Unregister-ScheduledTask -TaskName "${appName}.exe" -Confirm:$false -PassThru:$true
} catch {
    Write-Output "No task found with the name '${appName}.exe', skipping task removal."
}

# Schedule task to run the app on reboot
$taskAction = New-ScheduledTaskAction -Execute "$runPath\$appName.exe" -Argument "$options"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskPrincipal = New-ScheduledTaskPrincipal -UserID "System" -LogonType ServiceAccount
$taskSettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Days 31)
$task = New-ScheduledTask -Action $taskAction -Principal $taskPrincipal -Trigger $taskTrigger -Settings $taskSettings
Register-ScheduledTask -TaskName "${appName}.exe" -InputObject $task

Write-Output "FlexApp One $appName.exe, was run with $options."
