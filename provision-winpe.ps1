choco install -y windows-adk
choco install -y windows-adk-winpe
choco install -y 7zip
choco install -y carbon

.\copy-winpe.cmd

$mountPath = 'C:\winpe-amd64\mount'

Write-Output 'Mounting the Windows PE image...'
Mount-WindowsImage `
    -ImagePath C:\winpe-amd64\media\sources\boot.wim `
    -Index 1 `
    -Path $mountPath `
    | Out-Null

# see https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html
Write-Output 'Adding the virtio drivers...'
$qemuDriversIsoUrl = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.189-1/virtio-win-0.1.189.iso'
$qemuDriversIsoPath = "C:\vagrant\tmp\$(Split-Path -Leaf $qemuDriversIsoUrl)"
$qemuDriversPath = "$env:TEMP\$([IO.Path]::GetFileNameWithoutExtension($qemuDriversIsoUrl))"
if (!(Test-Path $qemuDriversIsoPath)) {
    mkdir -Force (Split-Path -Parent $qemuDriversIsoPath) | Out-Null
    (New-Object System.Net.WebClient).DownloadFile($qemuDriversIsoUrl, $qemuDriversIsoPath)
}
if (!(Test-Path $qemuDriversPath)) {
    7z x "-o$qemuDriversPath" $qemuDriversIsoPath
}
Get-ChildItem $qemuDriversPath -Include w10 -Recurse `
    | Where-Object { Test-Path "$_\amd64" } `
    | ForEach-Object {
        Write-Output "Adding the $_\amd64 driver..."
        Add-WindowsDriver -Path $mountPath -Driver "$_\amd64"
    }

$windowsOptionalComponentsPath = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs'
@(
    'WinPE-WMI'
    'WinPE-NetFx'
    'WinPE-PowerShell'
    'WinPE-DismCmdlets'
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
Grant-Permission "$mountPath\Windows\System32\winpe.jpg" Administrators FullControl
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

Write-Output 'Cleaning up the image...'
dism.exe /Quiet /Cleanup-Image "/Image=$mountPath" /StartComponentCleanup /ResetBase
if ($LASTEXITCODE) {
    throw "Failed with Exit Code $LASTEXITCODE"
}

Write-Output 'Saving and unmounting the Windows PE image...'
Dismount-WindowsImage -Path $mountPath -Save

.\make-winpe-iso.cmd
