# see https://github.com/s3fs-fuse/s3fs-fuse
# see https://github.com/rgl/s3fs-fuse-windows
# see https://github.com/rgl/s3fs-fuse-windows/releases/tag/v1.97.20271121

Write-Output 'Downloading s3fs-fuse...'
$artifactVersion = '1.97.20271121'
$artifactUrl = "https://github.com/rgl/s3fs-fuse-windows/releases/download/v$artifactVersion/s3fs-fuse.zip"
$artifactPath = "C:\vagrant\tmp\s3fs-fuse-$artifactVersion.zip"
if (!(Test-Path $artifactPath)) {
    mkdir -Force (Split-Path -Parent $artifactPath) | Out-Null
    (New-Object System.Net.WebClient).DownloadFile($artifactUrl, $artifactPath)
}

Write-Output 'Adding s3fs-fuse to WinPE...'
$destinationPath = "$env:WINDOWS_PE_MOUNT_PATH\Program Files\s3fs-fuse"
mkdir -Force (Split-Path -Parent $destinationPath) | Out-Null
Expand-Archive $artifactPath $destinationPath
