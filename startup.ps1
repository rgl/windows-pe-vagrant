$Host.UI.RawUI.WindowTitle = "PowerShell v$($PSVersionTable.PSVersion) :: Windows PE v$([Environment]::OSVersion.Version)"
Clear-Host

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
trap {
    Write-Output "ERROR: $_"
    Write-Output (($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1')
    Write-Output (($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1')
    while ($true) {
        Start-Sleep -Seconds 3
    }
    Exit 1
}

function Write-Title($title) {
    Write-Output "`n#`n# $title`n#`n"
}

# NB this was rendered by http://patorjk.com/software/taag/#p=display&f=Standard&t=Windows%20PE
@'
 __        ___           _                     ____  _____
 \ \      / (_)_ __   __| | _____      _____  |  _ \| ____|
  \ \ /\ / /| | '_ \ / _` |/ _ \ \ /\ / / __| | |_) |  _|
   \ V  V / | | | | | (_| | (_) \ V  V /\__ \ |  __/| |___
    \_/\_/  |_|_| |_|\__,_|\___/ \_/\_/ |___/ |_|   |_____| {0}
'@ -f @([Environment]::OSVersion.Version.Build)

# set the timezone, but keep the local time.
# NB Windows PE defaults to the Pacific Standard Time (-08:00; Redmond, Washington, USA) timezone.
# see HKLM\System\CurrentControlSet\Control\TimeZoneInformation
$date = (Get-Date -Format O) -replace '[-+]\d\d:\d\d$',''
Set-TimeZone 'GMT Standard Time' # Europe/Lisbon.
Set-Date $date | Out-Null

Write-Title Date
$timeZoneName = (Get-ItemProperty HKLM:\System\CurrentControlSet\Control\TimeZoneInformation).StandardName
Write-Output "$(Get-Date -Format O) ($timeZoneName)"

Write-title Firmware
$firmware = Get-ComputerInfo `
    -Property `
        BiosFirmwareType,
        BiosManufacturer,
        BiosVersion
Write-Output @"
Firmware Type:      $($firmware.BiosFirmwareType)
Firmware Vendor:    $($firmware.BiosManufacturer)
Firmware Version:   $($firmware.BiosVersion)
"@

Write-Title SMBIOS
$systemInfo = Get-CimInstance Win32_ComputerSystemProduct
$chassisInfo = Get-CimInstance Win32_SystemEnclosure
Write-Output @"
System Vendor:  $($systemInfo.Vendor)
System Product: $($systemInfo.Name)
System Version: $($systemInfo.Version)
System Serial:  $($systemInfo.IdentifyingNumber)
System Uuid:    $($systemInfo.UUID)
Chassis Vendor: $($chassisInfo.Manufacturer)
Chassis Serial: $($chassisInfo.SerialNumber)
Chassis Asset:  $($chassisInfo.SMBIOSAssetTag)
"@

Write-Output ''
