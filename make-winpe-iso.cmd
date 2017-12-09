call "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"

@echo Making winpe-amd64.iso...
call MakeWinPEMedia /iso /f c:\winpe-amd64 c:\vagrant\tmp\winpe-amd64.iso 2>&1 | findstr /v "% complete"
