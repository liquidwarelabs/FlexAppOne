# Enables 03 - 7Zip - File Archive.exe via Liquidware FlexApp One
#description: 03 - 7Zip - File Archive.exe via Liquidware FlexApp One
#tags: Liquidware FlexApp
#execution mode: Combined

# Only edit the following section #documentation
# For appName, do not add .exe #documentation
# appName and url parameters are usually Case Sensitive #documentation
# You can test the download by placing url/appName.exe in your browser #documentation
#
# JA mods - Create FlexApp download path if it doesn't exist 
$FlexAppPath = "C:\ProgramData\FlexAppOne"
If(!(test-path -PathType container $FlexAppPath))
{
    New-Item -ItemType Directory -Path $FlexAppPath
}
#
$appName = "03 - 7Zip - File Archive.exe" #parameter without the .exe
$url     = "https://fa1poc.blob.core.windows.net/fa1/poc" #parameter
$options = "--system --index 999 --ctl --addtostart" #parameter
$runPath = "C:\ProgramData\FlexappOne" #parameter
#
# Normally you do not edit past here

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
Start-Process -FilePath "$runPath\$AppName.exe" -ArgumentList "--stop --clean" -Wait
Write-host "FlexApp One $appName.exe, was run with --stop --clean."

# Run FlexApp with Options
Write-host "Loading new app."
Start-Process -FilePath "$runPath\$AppName.exe" -ArgumentList "$options"
Write-host "FlexApp One $appName.exe, was run with $options."

# Comment out evertthing below if you do not want to use the task scheduler to run the FlexApp.exe $options on boot
# Remove existing scheduled task with the same name
try {
?????? Unregister-ScheduledTask -TaskName "${appName}.exe" -Confirm:$false -PassThru:$true
} catch {
?????? Write-Output "No task found with the name '${appName}.exe', skipping task removal."
}

# Schedule task to run the app on reboot
$taskAction = New-ScheduledTaskAction -Execute "$runPath\$appName.exe" -Argument "$options"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskPrincipal = New-ScheduledTaskPrincipal -UserID "System" -LogonType ServiceAccount
$taskSettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Days 31)
$task = New-ScheduledTask -Action $taskAction -Principal $taskPrincipal -Trigger $taskTrigger -Settings $taskSettings
Register-ScheduledTask -TaskName "${appName}.exe" -InputObject $task

Write-host "FlexApp One $appName.exe, was run with $options."
