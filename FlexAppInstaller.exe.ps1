# Installs the FlexApp One Service.
# There are many ways to install FlexApp One centrally and to run - 'stream' or 'deploy' FlexApp / FlexApp One.

#description: Installs the FlexApp One Service. There are many ways to install FlexApp One centrally and to run - 'stream' or 'deploy' FlexApp / FlexApp One.
#tags: Liquidware FlexApp Service
#execution mode: Combined

# Only edit the following section                          #documentation
# For appName, do not add .exe                             #documentation
# appName and url parameters are usually Case Sensitive    #documentation
# You can test the download by placing url/appName.exe in your browser #documentation

#
#$appName = "NONE"                                          #parameter without the .exe
$installer = "installer"                                   #parameter without the .exe
$instoptions = "--install"                                 #parameter
$instcheck = "C:\Program Files\ProfileUnity\FlexApp\ContainerService\x64\VirtFsService.exe"  #parameter
$url     = "https://fa1poc.blob.core.windows.net/fa1/poc"  #parameter
#$options = "--system --index 999 --ctl --addtostart"       #parameter
$runPath = "C:\ProgramData\FlexAppOne"                     #parameter

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
