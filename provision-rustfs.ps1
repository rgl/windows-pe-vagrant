# install dependencies.
choco install --no-progress -y nssm carbon vcredist140
if ($LASTEXITCODE) {
    throw "bash execution failed with exit code $LASTEXITCODE (0x$($LASTEXITCODE.ToString('X8')))"
}

# install the rustfs s3 server.
$serviceName = 'rustfs'
$serviceUsername = "NT SERVICE\$serviceName"
$serviceHome = "C:\$serviceName"
$serviceLogsHome = "$serviceHome\logs"
$serviceDataHome = "$serviceHome\data"
$rustfs = "$serviceHome\bin\rustfs.exe"
$rc = "$serviceHome\bin\rc.exe"
Write-Host "Creating the $serviceName service..."
nssm install $serviceName $rustfs
nssm set $serviceName AppParameters `
    --address :9000 `
    --console-address :9001 `
    --console-enable `
    $serviceDataHome
nssm set $serviceName AppEnvironmentExtra `
    RUST_LOG=warn `
    RUSTFS_ACCESS_KEY=admin `
    RUSTFS_SECRET_KEY=admin
nssm set $serviceName AppDirectory $serviceHome
nssm set $serviceName Start SERVICE_AUTO_START
nssm set $serviceName AppRotateFiles 1
nssm set $serviceName AppRotateOnline 1
nssm set $serviceName AppRotateSeconds 86400
nssm set $serviceName AppRotateBytes 1048576
nssm set $serviceName AppStdout "$serviceHome\logs\$serviceName-stdout.log"
nssm set $serviceName AppStderr "$serviceHome\logs\$serviceName-stderr.log"
$result = sc.exe sidtype $serviceName unrestricted
if ($result -ne '[SC] ChangeServiceConfig2 SUCCESS') {
    throw "sc.exe sidtype failed with $result"
}
$result = sc.exe config $serviceName obj= $serviceUsername
if ($result -ne '[SC] ChangeServiceConfig SUCCESS') {
    throw "sc.exe config failed with $result"
}
$result = sc.exe failure $serviceName reset= 0 actions= restart/60000
if ($result -ne '[SC] ChangeServiceConfig2 SUCCESS') {
    throw "sc.exe failure failed with $result"
}
@(
    $serviceLogsHome
    $serviceDataHome
) | ForEach-Object {
    mkdir $_ -Force | Out-Null
    Disable-CAclInheritance $_
    Grant-CPermission $_ $serviceUsername FullControl
    Grant-CPermission $_ Administrators FullControl
    Grant-CPermission $_ $env:USERNAME FullControl
}
# see https://github.com/rustfs/rustfs/releases
$archiveVersion = '1.0.6'
$archiveUrl = "https://github.com/rustfs/rustfs/releases/download/$archiveVersion/rustfs-windows-x86_64-v$archiveVersion.zip"
$archivePath = "$env:TEMP\$(Split-Path -Leaf $archiveUrl)"
(New-Object Net.WebClient).DownloadFile($archiveUrl, $archivePath)
mkdir "$serviceHome\bin" -Force | Out-Null
Expand-Archive $archivePath -DestinationPath "$serviceHome\bin"
Remove-Item $archivePath
# see https://github.com/rustfs/cli/releases
$archiveVersion = '0.1.38'
$archiveUrl = "https://github.com/rustfs/cli/releases/download/v$archiveVersion/rustfs-cli-windows-amd64-v$archiveVersion.zip"
$archivePath = "$env:TEMP\$(Split-Path -Leaf $archiveUrl)"
(New-Object Net.WebClient).DownloadFile($archiveUrl, $archivePath)
Expand-Archive $archivePath -DestinationPath "$serviceHome\bin"
Remove-Item $archivePath
Start-Service $serviceName
&$rc alias set local http://localhost:9000 admin admin
&$rc admin info server local
&$rc mb local/test
# allow anonymous access to bucket content.
# e.g. to http://localhost:9000/test/index.html
&$rc anonymous set download local/test
Set-Content -Encoding ascii -Path "$env:TEMP\index.html" -Value @"
<!doctype html>
<html>
<head><title>Hello, World!</title></head>
<body>Hello, World!</body>
</html>
"@
&$rc cp "$env:TEMP\index.html" local/test/
&$rc stat local/test/index.html
&$rc tag set --tags example-tag=example-value -- local/test/index.html
&$rc tag list local/test/index.html
&$rc ls local/test
Set-Content -Encoding ascii -Path "$env:TEMP\rustfs-policy-winpe.json" -Value @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnly",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::*"
      ],
      "Condition": {}
    }
  ]
}
"@
&$rc admin policy create local winpe "$env:TEMP\rustfs-policy-winpe.json"
&$rc admin user add local winpe password
&$rc admin policy attach local winpe --user winpe
[IO.File]::WriteAllText(
    "$env:USERPROFILE\Desktop\RustFS.url",
    @"
[InternetShortcut]
URL=http://localhost:9000
"@)
[IO.File]::WriteAllText(
    "$env:USERPROFILE\Desktop\RustFS Test Index.url",
    @"
[InternetShortcut]
URL=http://localhost:9000/test/index.html
"@)
[IO.File]::WriteAllText(
    "$env:USERPROFILE\Desktop\RustFS Console.url",
    @"
[InternetShortcut]
URL=http://localhost:9001
"@)

Write-Host 'Creating the firewall rule to allow inbound TCP/IP access to the RustFS port 9000...'
New-NetFirewallRule `
    -Name 'RustFS-In-TCP' `
    -DisplayName 'RustFS (TCP-In)' `
    -Direction Inbound `
    -Enabled True `
    -Protocol TCP `
    -LocalPort 9000 `
    | Out-Null
