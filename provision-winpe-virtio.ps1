# see https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html
# see https://github.com/virtio-win/virtio-win-guest-tools-installer
# see https://github.com/virtio-win/virtio-win-pkg-scripts
Write-Output 'Adding the virtio drivers...'
$qemuDriversIsoUrl = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.215-2/virtio-win-0.1.215.iso'
$qemuDriversIsoPath = "C:\vagrant\tmp\$(Split-Path -Leaf $qemuDriversIsoUrl)"
$qemuDriversPath = "$env:TEMP\$([IO.Path]::GetFileNameWithoutExtension($qemuDriversIsoUrl))"
if (!(Test-Path $qemuDriversIsoPath)) {
    mkdir -Force (Split-Path -Parent $qemuDriversIsoPath) | Out-Null
    (New-Object System.Net.WebClient).DownloadFile($qemuDriversIsoUrl, $qemuDriversIsoPath)
}
if (!(Test-Path $qemuDriversPath)) {
    7z x "-o$qemuDriversPath" $qemuDriversIsoPath
}
Get-ChildItem $qemuDriversPath -Include 2k22 -Recurse `
    | Where-Object { Test-Path "$_\amd64" } `
    | ForEach-Object {
        Write-Output "Adding the $_\amd64 driver..."
        Add-WindowsDriver -Path $env:WINDOWS_PE_MOUNT_PATH -Driver "$_\amd64"
    }
