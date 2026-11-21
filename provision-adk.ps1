Import-Module C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1

function Get-StringHash($text) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $hash = Get-FileHash -InputStream ([System.IO.MemoryStream]::new($bytes)) -Algorithm SHA1
    $hash.Hash.ToLowerInvariant()
}

# Install the Windows Assessment and Deployment Kit (ADK) 10.1.26100.9457 (September 2026).
# see https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
$adkUrl = 'https://download.microsoft.com/download/8e0c0f5a-abb5-4358-a51b-168eb40b1590/adk/adksetup.exe'
$winpeAdkAddonUrl = 'https://download.microsoft.com/download/a4a79e7a-f085-41c4-aebf-2538fd000790/adkwinpeaddons/adkwinpesetup.exe'

function Install-Adk($title, $url) {
    $artifactPath = "C:\vagrant\tmp\$(Get-StringHash $url)-$(Split-Path -Leaf $url)"
    if (!(Test-Path $artifactPath)) {
        mkdir -Force (Split-Path -Parent $artifactPath) | Out-Null
        Write-Host "Downloading $title..."
        (New-Object System.Net.WebClient).DownloadFile($url, "$artifactPath.tmp")
        Move-Item "$artifactPath.tmp" $artifactPath
    }
    $mountedImage = $null
    if ($artifactPath -like '*.iso') {
        Write-Host 'Mounting image...'
        $mountedImage = Mount-DiskImage -Passthru $artifactPath
        $mountedVolume = $mountedImage | Get-Volume
        $setupPath = Resolve-Path "$($mountedVolume.DriveLetter):\*.exe"
    } else {
        $setupPath = $artifactPath
    }
    try {
        Write-Host "Installing $title..."
        &$setupPath @args | Out-String -Stream
    } finally {
        if ($mountedImage) {
            Write-Host 'Dismounting image...'
            Dismount-DiskImage $artifactPath | Out-Null
        }
    }
}

Install-Adk `
    'Windows Assessment and Deployment Kit (ADK)' `
    $adkUrl `
    /quiet /log "$env:TEMP\adk.log" /features OptionId.DeploymentTools

Install-Adk `
    'WinPE add-on for the Windows Assessment and Deployment Kit (ADK)' `
    $winpeAdkAddonUrl `
    /quiet /log "$env:TEMP\adk-winpe.log"

Write-Host 'Creating the Windows System Image Manager shortcut in the Desktop...'
Install-ChocolateyShortcut `
    -ShortcutFilePath "$env:USERPROFILE\Desktop\Windows System Image Manager.lnk" `
    -TargetPath 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\WSIM\amd64\imgmgr.exe'
