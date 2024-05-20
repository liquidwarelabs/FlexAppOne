# Enables VLCPlayer - Popular Media Player via Liquidware FlexApp One.
# There are many ways to centrally 'stream' or 'deploy' FlexApp / FlexApp One.
# Unregister Error is normal if the ScheduledTask does not already exist.

#description: Enables VLCPlayer - Popular Media Player via Liquidware FlexApp One. There are many ways to centrally 'stream' or 'deploy' FlexApp / FlexApp One.
#tags: Liquidware FlexApp
#execution mode: Combined

# Only edit the following section                          #documentation
# For appName, do not add .exe                             #documentation
# appName and url parameters are usually Case Sensitive    #documentation
# You can test the download by placing url/appName.exe in your browser #documentation

#
$appName = "14 - VLC Player - Media Player"               #parameter without the .exe
$url     = "https://fa1poc.blob.core.windows.net/fa1/poc"  #parameter
$options = "--system --index 999 --ctl --addtostart"       #parameter
$runPath = "C:\ProgramData\FlexAppOne"                     #parameter
#
# Normally you do not edit past here

#Create FlexApp One download location - runPath
If(!(test-path -PathType container $runPath))
{
    New-Item -ItemType Directory -Path $runPath
}

# Download required files for the app
Write-Output "Downloading latest version of '$appName' from $url"
$startTime = Get-Date

# BitsTransfer module
Import-Module BitsTransfer
Start-BitsTransfer -Source $url/$appName.exe -Destination "$runPath\$appName.exe"
Write-Output "Time taken: $((Get-Date).Subtract($startTime).Seconds) second(s)"
Write-host "New application downloaded."

# Stop Clean the app before running
Write-host "Stop Clean app."
Start-Process -FilePath "$runPath\$appName.exe" -ArgumentList "--stop --clean" -Wait
Write-host "FlexApp One $appName.exe, was run with --stop --clean."

# Run FlexApp with Options
Write-host "Loading new app."
Start-Process -FilePath "$runPath\$appName.exe" -ArgumentList "$options"
Write-host "FlexApp One $appName.exe, was run with $options."

# Comment out everything below if you do not want to use the task scheduler to run the FlexApp.exe $options on boot
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

Write-host "FlexApp One $appName.exe, was run with $options."