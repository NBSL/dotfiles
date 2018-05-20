Get-Process vcxsrv 2>&1 | Out-Null 
IF ( $false -eq $? ) {
    Start-Process "C:\Program Files\VcXsrv\vcxsrv.exe" ":0 -ac -terminate -lesspointer -multiwindow -clipboard -wgl -dpi auto"
}

Start-Process bash.exe "-c -l `"DISPLAY=:0 nohup terminator >/dev/null 2>&1 &`" "