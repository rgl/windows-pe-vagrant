Import-Module Carbon

$adkPath = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
$mountPath = 'C:\winpe-amd64\mount'

if (Test-Path "$mountPath\Windows") {
    Write-Output 'Discarding and unmounting the existing Windows PE image...'
    Dismount-WindowsImage -Path $mountPath -Discard
    Remove-Item -Recurse $mountPath
}

cmd /c copy-winpe.cmd

Write-Output 'Mounting the Windows PE image...'
Mount-WindowsImage `
    -ImagePath C:\winpe-amd64\media\sources\boot.wim `
    -Index 1 `
    -Path $mountPath `
    | Out-Null

$windowsOptionalComponentsPath = "$adkPath\Windows Preinstallation Environment\amd64\WinPE_OCs"
@(
    'WinPE-WMI'
    'WinPE-NetFx'
    'WinPE-PowerShell'
    'WinPE-DismCmdlets'
    'WinPE-SecureStartup'
    'WinPE-SecureBootCmdlets'
) | ForEach-Object {
    Write-Output "Adding the $_ Windows Package..."
    Add-WindowsPackage `
        -Path $mountPath `
        -PackagePath "$windowsOptionalComponentsPath\$_.cab" `
        | Out-Null
}

Write-Output 'Adding the startup files...'
Copy-Item startup.ps1 $mountPath
Copy-Item winpeshl.ini "$mountPath\Windows\System32"
Grant-CPermission "$mountPath\Windows\System32\winpe.jpg" Administrators FullControl
Copy-Item winpe.jpg "$mountPath\Windows\System32"
<#
# this is commented because changing the background color does not seem to be supported on winpe.
# see the registry hive supporting files at https://msdn.microsoft.com/en-us/library/windows/desktop/ms724877(v=vs.85).aspx
reg load HKLM\WINPE_DEFAULT "$mountPath\Windows\System32\config\DEFAULT" | Out-Null
New-PSDrive -PSProvider Registry -Name WINPE_DEFAULT -Root HKEY_LOCAL_MACHINE\WINPE_DEFAULT | Out-Null
Set-ItemProperty -Path 'WINPE_DEFAULT:\Control Panel\Desktop' -Name WallpaperStyle -Value 0
Set-ItemProperty -Path 'WINPE_DEFAULT:\Control Panel\Desktop' -Name TileWallpaper -Value 0
Set-ItemProperty -Path 'WINPE_DEFAULT:\Control Panel\Colors' -Name Background -Value '1 30 171'
Remove-PSDrive WINPE_DEFAULT
reg unload HKLM\WINPE_DEFAULT | Out-Null
#>

Write-Output 'Customizing the image...'
Get-ChildItem provision-winpe-*.ps1 | Sort-Object FullName | ForEach-Object {
    .\ps.ps1 $_
}

Write-Output 'Cleaning up the image...'
dism.exe /Quiet /Cleanup-Image "/Image=$mountPath" /StartComponentCleanup /ResetBase
if ($LASTEXITCODE) {
    throw "Failed with Exit Code $LASTEXITCODE"
}

Write-Output 'Saving and unmounting the Windows PE image...'
Dismount-WindowsImage -Path $mountPath -Save

# NB this removes the "Press any key to boot from CD or DVD" prompt
#    that appears when running in UEFI with the default efisys.bin.
Write-Output 'Replacing fwfiles\efisys.bin with efisys_noprompt.bin...'
Copy-Item `
    "$adkPath\Deployment Tools\amd64\Oscdimg\efisys_noprompt.bin" `
    "$mountPath\..\fwfiles\efisys.bin"

Write-Output 'Creating the Windows PE iso file...'
cmd /c make-winpe-iso.cmd
