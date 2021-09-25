Import-Module C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1

# Install the Windows 2022 Assessment and Deployment Kit (ADK) 10.1.22000.1.
# see https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
$adkUrl = 'https://software-download.microsoft.com/download/sg/20348.1.210507-1500.fe_release_amd64fre_ADK.iso'
$winpeAdkAddonUrl = 'https://software-download.microsoft.com/download/sg/20348.1.210507-1500.fe_release_amd64fre_ADKWINPEADDONS.iso'

function Install-Adk($title, $url) {
    $artifactPath = "C:\vagrant\tmp\$(Split-Path -Leaf $url)"
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
    /quiet /features OptionId.DeploymentTools

Install-Adk `
    'WinPE add-on for the Windows Assessment and Deployment Kit (ADK)' `
    $winpeAdkAddonUrl `
    /quiet

Write-Host 'Creating the Windows System Image Manager shortcut in the Desktop...'
Install-ChocolateyShortcut `
    -ShortcutFilePath "$env:USERPROFILE\Desktop\Windows System Image Manager.lnk" `
    -TargetPath 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\WSIM\imgmgr.exe'
