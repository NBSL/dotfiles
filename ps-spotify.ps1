# Inspiration from
# Silent Install 7-Zip
# http://www.7-zip.org/download.html
# https://forum.pulseway.com/topic/1939-install-7-zip-with-powershell/

# Check for admin rights
$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
$adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $prp.IsInRole($adm)) {
    throw "This script requires elevated rights to install software.. Please run from an elevated shell session."
}

# Check for 7z install
Write-Progress -Activity "Validating Dependencies" -Status "Checking for 7zip"
$7z_Application = get-command 7z.exe -ErrorAction SilentlyContinue | select-object -expandproperty Path
if ([string]::IsNullOrEmpty($7z_Application)) {
    $7z_Application = "C:\Program Files\7-Zip\7z.exe"
}

if (-not (Test-Path $7z_Application)) {
    Write-Progress -Activity "Validating Dependencies" -Status "Installing 7zip"
    # Path for the workdir
    $workdir = "c:\installer\"

    # Check if work directory exists if not create it
    If (-not (Test-Path -Path $workdir -PathType Container)) {
        New-Item -Path $workdir  -ItemType directory
    }

    # Download the installer
    $source = "http://www.7-zip.org/a/7z1801-x64.msi"
    $destination = "$workdir\7-Zip.msi"

    Invoke-WebRequest $source -OutFile $destination

    # Start the installation
    msiexec.exe /i "$workdir\7-Zip.msi" /qb
    # Wait XX Seconds for the installation to finish
    Start-Sleep -s 35

    # Remove the installer
    Remove-Item -Force $workdir\7*
    Write-Progress -Activity "Validating Dependencies" -Status "Installing 7zip" -Completed
}

Write-Progress -Activity "Downloading ps-spotify from https://github.com/bmsimons/ps-spotify"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://github.com/bmsimons/ps-spotify/archive/master.zip" -OutFile $env:USERPROFILE\Downloads\ps-spotify.zip

Write-Progress -Activity "Extracting ps-spotify..."
if(-not (Test-Path -PathType Container $env:USERPROFILE\Documents\WindowsPowerShell\Modules)) {
  New-Item -ItemType Directory -Force -Path $env:USERPROFILE\Documents\WindowsPowerShell\Modules
}
Get-Item "$($env:USERPROFILE)\Downloads\ps-spotify.zip" | ForEach-Object {
    $7z_Arguments = @(
        'x'							## eXtract files with full paths
        '-y'						## assume Yes on all queries
        "`"-o$($env:USERPROFILE)\Documents\WindowsPowerShell\Modules\`""		## set Output directory
        "`"$($_.FullName)`""				## <archive_name>
    )
    & $7z_Application $7z_Arguments
    ##If ($LASTEXITCODE -eq 0) {
    ##    Remove-Item -Path $_.FullName -Force
    ##}
}
Write-Progress -Activity "Adding import to $env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if(-not (Get-Module -ListAvailable -Name ps-spotify)){
  Add-Content $env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 "`nImport-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\ps-spotify-master\ps-spotify"
  Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\ps-spotify-master\ps-spotify
}
