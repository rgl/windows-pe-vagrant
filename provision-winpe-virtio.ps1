# see https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html
# see https://github.com/virtio-win/virtio-win-guest-tools-installer
# see https://github.com/virtio-win/virtio-win-pkg-scripts
Write-Output 'Adding the virtio drivers...'
$qemuDriversIsoUrl = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.248-1/virtio-win-0.1.248.iso'
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
        Get-ChildItem "$_\amd64\*.inf" | ForEach-Object {
            $driverPath = $_.FullName
            Write-Output "Adding the $driverPath driver..."
            try {
                Add-WindowsDriver -Path $env:WINDOWS_PE_MOUNT_PATH -Driver $driverPath
            } catch {
                # NB as-of virtio-win 0.1.248, the following drivers fail to be added:
                #       pvpanic-pci.inf
                #       smbus.inf
                # see https://github.com/virtio-win/kvm-guest-drivers-windows/issues/1107
                if ("$_" -match 'The request is not supported') {
                    Write-Host "WARNING The driver was not added. Ignoring the known error: $_"
                    return
                }
                throw
            }
        }
    }
