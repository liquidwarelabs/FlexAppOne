# ============================================================================
# FlexApp One Service Installer — FleetCTRL
# ============================================================================
#
# ---- EDIT THESE VALUES ----
#
    $url = "https://fa1poc.blob.core.windows.net/fa1/poc"  # Download URL (without filename)
#
# ---- FleetCTRL Metadata ----
# DESCRIPTION:     Installs the FlexApp One service (LWLContainerService) and driver
# TAGS:            Liquidware FlexApp Service
# EXECUTION MODE:  Combined
# TYPE:            service
# CATEGORY:        FlexApp Service
# VERSION:         1.0.0.0
# UNINSTALL:       "C:\ProgramData\FlexAppOne\installer.exe" --uninstall
# DETECTIONRULE:   file:"C:\Program Files\ProfileUnity\FlexApp\ContainerService\x64\VirtFsService.exe"
#
# ---- DO NOT EDIT BELOW THIS LINE ----
# ============================================================================

$runPath   = "C:\ProgramData\FlexAppOne"
$instcheck = "C:\Program Files\ProfileUnity\FlexApp\ContainerService\x64\VirtFsService.exe"

# ---- Uninstall mode (called by FleetCTRL with --uninstall) ----
if ($args -contains '--uninstall') {
    if (Test-Path "$runPath\installer.exe") {
        Start-Process -FilePath "$runPath\installer.exe" -ArgumentList "--uninstall" -NoNewWindow -Wait
        Write-Output "FlexApp One service uninstalled."
    } else {
        Write-Output "Installer not found at $runPath\installer.exe"
    }
    exit 0
}

# ---- Install ----
if (Test-Path $instcheck) {
    Write-Output "FlexApp One service already installed: $instcheck"
    exit 0
}

Write-Output "FlexApp One service not found — installing..."
New-Item -ItemType Directory -Force -Path $runPath | Out-Null
Import-Module BitsTransfer
Start-BitsTransfer -Source "$url/installer.exe" -Destination "$runPath\installer.exe"
Start-Process -FilePath "$runPath\installer.exe" -ArgumentList "--install" -NoNewWindow -Wait
Write-Output "FlexApp One service installed."
