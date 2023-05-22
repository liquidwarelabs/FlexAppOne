#-------------Edit starting here, typically the AppName, Download Path, Description, Tags and Notes
#description: Deletes all FlexApps within ProgramData\FlexAppOne and Scheduled Tasks
#tags: Liquidware FlexApp
#execution mode: Combined

    <#
      Notes:
      This FlexApp One is hosted on a Liquidware blob location.
    #>

$FlexAppPath = "C:\ProgramData\FlexAppOne"
$options = "--system --stop --clean --remove"

#-------------Normally you will not edit past here
$ProgressPreference = 'SilentlyContinue'

Get-ChildItem "$FlexAppPath\*.exe" -Recurse | ForEach-Object {
    Write-Output "(FA1) $($_.BaseName).exe removing task"   
    Start-Process -FilePath "schtasks.exe" -ArgumentList "/Delete /tn `"(FA1)\$($_.BaseName).exe`" /f"
}

Get-ChildItem "$FlexAppPath\*.exe" -Recurse | ForEach-Object {
    Write-Output "$($_.FullName) found file"
    Start-Process -FilePath $_.FullName -ArgumentList "$options"
    Remove-Item -Path "$_.cmd"
    Remove-Item -Path "$_.xml"
    Write-Output "$($_.FullName) removed"
}