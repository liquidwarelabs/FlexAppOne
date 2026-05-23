# FlexApp One — FleetCTRL Script Templates

Deploy, manage, and remove applications on AVD session hosts without traditional MSI installs. FlexApp One packages applications as self-contained EXEs that mount as virtual layers — no install footprint, instant delivery, clean removal. Create your own repository, point to your own blob storage, and deploy applications across your host pools.

## Quick Start

1. Add this repository to FleetCTRL (Settings → GitHub Repos)
2. FleetCTRL syncs the scripts and makes them available in the App Catalog
3. Deploy apps to host pools from the App Catalog or Host Pool → Deploy App
4. Manage deployed apps from the Deployed Apps page (verify, update, remove)

## Included Scripts

| Script | Type | Description |
|--------|------|-------------|
| `01 - 3D Pinball Win95-98 - Game.exe.ps1` | App | Sample game — tests FA1 mount/unmount |
| `14 - VLC Player - Media Player.exe.ps1` | App | VLC media player |
| `18 - FireFox.exe - Internet Browser.exe.ps1` | App | Firefox browser |
| `21 - OnlyOffice - like Office.exe.ps1` | App | OnlyOffice productivity suite |
| `FlexAppInstaller.exe.ps1` | Service | Installs the FlexApp One service and driver |
| `RemoveAllFA1.ps1` | Utility | Removes ALL FlexApp One apps from a host |

## Script Structure

Every script follows the same template. Users edit 3 values at the top — everything else is framework code:

```powershell
# ---- EDIT THESE 3 VALUES ----
#
    $appName = "My App Name"                              # App name (without .exe)
    $url     = "https://myblobstorage.com/fa1/apps"       # Download URL (without filename)
    $options = "--system --index 999 --ctl --addtostart"   # FA1 launch options
#
# ---- FleetCTRL Metadata ----
# DESCRIPTION:     My App Name via FlexApp One
# TAGS:            Liquidware FlexApp
# EXECUTION MODE:  Combined
# TYPE:            app
# CATEGORY:        FlexApp Applications
# VERSION:         1.0.0.0
# UNINSTALL:       "C:\ProgramData\FlexAppOne\My App Name.exe" --system --stop --clean --remove
# DETECTIONRULE:   file:"%programdata%\Microsoft\Windows\Start Menu\Programs\FlexApp One\My App Name.lnk"
#
# ---- DO NOT EDIT BELOW THIS LINE ----
```

## Metadata Tags

FleetCTRL parses these tags from the script header. They control how the app appears in the UI and enable lifecycle features:

| Tag | Required | Description |
|-----|----------|-------------|
| `# DESCRIPTION:` | Yes | What the script does — shown in the App Catalog |
| `# TAGS:` | No | Search/filter tags |
| `# EXECUTION MODE:` | No | `Combined` (default), `Serial`, or `Parallel` |
| `# TYPE:` | No | `app` (default), `service`, `utility`, `utility_remove_all` |
| `# CATEGORY:` | No | Grouping in the App Catalog (e.g., "FlexApp Applications") |
| `# VERSION:` | No | Semver format `1.0.0.0` — shown in UI, bump when updating the app package |
| `# UNINSTALL:` | No | Documents the native uninstall command — enables the Remove button in Deployed Apps |
| `# DETECTIONRULE:` | No | How to check if the app is installed — enables the Verify button in Deployed Apps |

**Tag format:** `# TAG:` followed by spaces and the value. Case insensitive, spacing flexible.

## Detection Rules

Detection rules tell FleetCTRL how to verify an app is installed on a host:

| Prefix | Example | Checks |
|--------|---------|--------|
| `file:` | `file:"%programdata%\...\My App.lnk"` | File exists (PowerShell `Test-Path`) |
| `reg:` | `reg:"HKLM\Software\FlexApp\My App.exe"` | Registry key exists |
| `custom:` | `custom:powershell -Command "..."` | Custom command (exit 0 = installed) |

FlexApp One apps use `--addtostart` which creates a `.lnk` in the Start Menu — use `file:` detection. Apps using `--reg` create a registry key — use `reg:` detection.

**Quote paths with spaces** for clarity. FleetCTRL strips quotes automatically.

## Uninstall Support

Scripts with a `# UNINSTALL:` tag support removal via FleetCTRL. The script must include an `--uninstall` handler:

```powershell
if ($args -contains '--uninstall') {
    # 1. Remove scheduled task
    # 2. Run the FA1 EXE with --system --stop --clean --remove
    # 3. Delete the downloaded EXE
    exit 0
}
```

When an admin clicks "Remove" in Deployed Apps, FleetCTRL runs the script with `--uninstall` on each host.

## FlexApp One CLI Reference

Key command line arguments for FlexApp One application EXEs:

| Argument | Description |
|----------|-------------|
| `--system` | Use Public areas (HKLM, Public Start Menu) instead of per-user |
| `--index 999` | Mount the layer without launching shortcuts |
| `--ctl` | Create Desktop and Start Menu shortcuts |
| `--addtostart` | Add to Start Menu → Programs → FlexApp One folder |
| `--stop` | Stop and unmount the application layer |
| `--clean` | Remove shortcuts, registry key, and write cache (use with `--stop`) |
| `--remove` | Delete the FlexApp One EXE from disk (requires `--stop`) |
| `--reg` | Create detection registry key at `HKLM\Software\FlexApp\App.exe` (with `--system`) |
| `--replace <path>` | Replace and restart with a new version |
| `--install` | Install the FlexApp One service and driver (installer.exe only) |
| `--uninstall` | Remove the FlexApp One service and driver (installer.exe only) |

**Install pattern:** `app.exe --system --index 999 --ctl --addtostart`
**Uninstall pattern:** `app.exe --system --stop --clean --remove`

## Creating Your Own FlexApp One App Script

1. Package your application using the [FlexApp Packaging Console](https://www.liquidware.com/products/flexapp)
2. Upload the `.exe` package to Azure Blob Storage (or any HTTPS-accessible URL)
3. Copy one of the sample scripts (e.g., `01 - 3D Pinball...`)
4. Change the 3 values at the top: `$appName`, `$url`, `$options`
5. Update the metadata: `# DESCRIPTION:`, `# VERSION:`, `# UNINSTALL:`, `# DETECTIONRULE:`
6. Commit to your GitHub repo
7. FleetCTRL syncs it automatically — the app appears in the App Catalog

## Creating a Custom (Non-FA1) Script

FleetCTRL scripts aren't limited to FlexApp One. Any PowerShell script can use the metadata tags:

```powershell
# ---- EDIT THESE VALUES ----
#
    $appName = "My MSI App"
    $msiPath = "\\fileserver\share\MyApp.msi"
#
# ---- FleetCTRL Metadata ----
# DESCRIPTION:     Install My MSI App
# CATEGORY:        Custom Apps
# VERSION:         2.1.0.0
# UNINSTALL:       msiexec /x {PRODUCT-GUID} /quiet
# DETECTIONRULE:   reg:"HKLM\SOFTWARE\MyCompany\MyApp"
#
# ---- DO NOT EDIT BELOW THIS LINE ----

if ($args -contains '--uninstall') {
    Start-Process msiexec -ArgumentList "/x {PRODUCT-GUID} /quiet" -Wait
    exit 0
}

Start-Process msiexec -ArgumentList "/i `"$msiPath`" /quiet" -Wait
Write-Output "Installed: $appName"
```
