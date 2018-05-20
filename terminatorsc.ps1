# Check for admin rights
$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
$adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $prp.IsInRole($adm)) {
    throw "This script requires elevated rights to install software.. Please run from an elevated shell session."
}

$symlink = "$env:USERPROFILE\Desktop\terminator.lnk"
If (-not (Test-Path -Path $symlink)) {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\terminator.lnk")
    $Shortcut.TargetPath = "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"
    $Shortcut.Arguments = "$pwd\terminator.ps1"
    $Shortcut.IconLocation= "$pwd\Terminator.ico"
    $Shortcut.Save()
}