$Host.UI.RawUI.WindowTitle = "PowerShell v$($PSVersionTable.PSVersion) :: Windows PE v$([Environment]::OSVersion.Version)"
cls

# NB this was rendered by http://patorjk.com/software/taag/#p=display&f=Standard&t=Windows%20PE
@'
 __        ___           _                     ____  _____
 \ \      / (_)_ __   __| | _____      _____  |  _ \| ____|
  \ \ /\ / /| | '_ \ / _` |/ _ \ \ /\ / / __| | |_) |  _|
   \ V  V / | | | | | (_| | (_) \ V  V /\__ \ |  __/| |___
    \_/\_/  |_|_| |_|\__,_|\___/ \_/\_/ |___/ |_|   |_____| {0}

'@ -f @((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId)
