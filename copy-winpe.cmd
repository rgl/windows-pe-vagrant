call "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"

@echo Copying WinPE files...
if exist c:\winpe-amd64 (rmdir /s /q c:\winpe-amd64)
call copype amd64 c:\winpe-amd64
