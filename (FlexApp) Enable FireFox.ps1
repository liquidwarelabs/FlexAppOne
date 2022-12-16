#-------------Edit starting here, typically the AppName, Download Path, Description, Tags and Notes
$AppName = "FireFox" #case-sensitive and no .exe
$DownloadPath = "https://fa1poc.blob.core.windows.net/fa1/poc"
#description: Enables FireFox
#tags: Liquidware FlexApp
#execution mode: Combined
    <#
      Notes:
      This FlexApp One is hosted on a Liquidware blob location.
    #>
#-------------Normally you will not edit past here
$ProgressPreference = 'SilentlyContinue'

#If you do change the path, you need to change the AppName.exe.xml and re-run the script that generate the .XML, .CMD and Manifest.txt file
$FlexAppPath = "C:\ProgramData\FlexAppOne"
mkdir $FlexAppPath

#Download and install FlexApp service
if (!(Test-Path "C:\Program Files\ProfileUnity\Flexapp\ContainerService\x64\VirtFsService.exe"))
{
Invoke-WebRequest -OutFile "$FlexAppPath\Installer.exe" -URI "$DownloadPath/installer.exe"
Start-Process -FilePath "$FlexAppPath\Installer.exe" -ArgumentList "-i"
}

#Download .cmd, .xml, and .exe files
Invoke-WebRequest -OutFile "$FlexAppPath\$AppName.exe" -URI "$DownloadPath/$AppName.exe"
Invoke-WebRequest -OutFile "$FlexAppPath\$AppName.exe.xml" -URI "$DownloadPath/$AppName.exe.xml"
Invoke-WebRequest -OutFile "$FlexAppPath\$AppName.exe.cmd" -URI "$DownloadPath/$AppName.exe.cmd"

#Create scheduled task to mount app on restart
Start-Process -FilePath "schtasks.exe" -ArgumentList "/Delete /tn `"(FA1)\$AppName.exe`" /f"
Start-Process -FilePath "schtasks.exe" -ArgumentList "/Create /XML `"$FlexAppPath\$AppName.exe.xml`" /tn `"(FA1)\$AppName.exe`" /ru system"

#Mount app
Start-Process -FilePath "$FlexAppPath\$AppName.exe" -ArgumentList "--system --index 999"
timeout /t 5
Start-Process -FilePath "$FlexAppPath\$AppName.exe" -ArgumentList "--system --ctl --addtostart --skipactivation"
