# see https://github.com/winfsp/winfsp/releases/tag/v2.1
# see https://github.com/winfsp/winfsp/blob/v2.1/tools/winfsp-winpe.bat
# see https://github.com/winfsp/winfsp/issues/404
# see https://community.chocolatey.org/packages/winfsp

Write-Output 'Installing winfsp...'
choco install -y winfsp --version 2.1.25156

Write-Output 'Adding winfsp to WinPE...'
# NB regsvr32 /s winfsp-x64.dll is executed from winpeshl.ini.
$winFspHomePath = 'C:\Program Files (x86)\WinFsp'
Copy-Item "$winFspHomePath\bin\winfsp-x64.sys"  "$env:WINDOWS_PE_MOUNT_PATH\Windows\System32"
Copy-Item "$winFspHomePath\bin\winfsp-x64.dll"  "$env:WINDOWS_PE_MOUNT_PATH\Windows\System32"
Copy-Item "$winFspHomePath\bin\memfs-x64.exe"   "$env:WINDOWS_PE_MOUNT_PATH\Windows\System32"
