Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module burnttoast
Import-Module burnttoast

$Time = Get-date -Format t
$Btn = New-BTButton -Content 'OK' -arguments 'ok'
$Splat = @{
    Text = 'Zed: Starting Installs' , "Let's give this PC some apps and settings. Started $Time"
    Applogo = 'https://iili.io/H8B8JtI.png'
    Sound = 'IM'
    Button = $Btn
    HeroImage = 'https://iili.io/HU77iLN.jpg'
}
New-BurntToastNotification @splat 

Start-Transcript -Path "C:\ezNetworking\Automation\Logs\ezCloudDeploy_111_Windows_PostOS_DefaultAppsAndOnboard.log"
# Install Choco and minimal default packages
write-host "1._____________________________________________________________"
write-host " Zed says: Installing Chocolatey"

try {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Start-Sleep -s 30
}
catch {
    Write-Error " Zed says: Chocolatey is already installed or had an error $($_.Exception.Message)"
}

# -y confirm yes for any prompt during the install process
write-host " Zed says: Installing Chocolatey packages"
choco install googlechrome -y
choco install treesizefree -y
choco install tailblazer -y

write-host "2._____________________________________________________________"

# Install ezRmm and ezRS
write-host " Zed says: reading the ezClientConfig.json file"
$ezClientConfig = Get-Content -Path "C:\ezNetworking\Automation\ezCloudDeploy\ezClientConfig.json" | ConvertFrom-Json

write-host " Zed says: Downloading ezRmmInstaller.msi and installing it for customer $($ezClientConfig.ezRmmId)"
$Splat = @{
    Text = 'Zed: Installing ez RMM' , "Downloading and installing... Started $Time"
    Applogo = 'https://iili.io/H8B8JtI.png'
    Sound = 'IM'
}
New-BurntToastNotification @splat 

try {
    $ezRmmUrl = "http://support.ez.be/GetAgent/Msi/?customerId=$($ezClientConfig.ezRmmId)" + '&integratorLogin=jurgen.verhelst%40ez.be'
    write-host " Zed says: Downloading ezRmmInstaller.msi from $ezRmmUrl"
    Invoke-WebRequest -Uri $ezRmmUrl -OutFile "C:\ezNetworking\Automation\ezCloudDeploy\ezRmmInstaller.msi"
    Start-Process -FilePath "C:\ezNetworking\Automation\ezCloudDeploy\ezRmmInstaller.msi" -ArgumentList "/quiet" -Wait
    
}
catch {
    Write-Error " Zed says: ezRmm is already installed or had an error $($_.Exception.Message)"
}

write-host "3._____________________________________________________________"
write-host " Zed says: Downloading and installing ezRS"
write-host " Zed says: Downloading ezRmmInstaller.msi and installing it"
$Splat = @{
    Text = 'Zed: Installing ez Remote Support' , "Downloading and installing... Started $Time"
    Applogo = 'https://iili.io/H8B8JtI.png'
    Sound = 'IM'
}
New-BurntToastNotification @splat 

try {
    $ezRsUrl = 'https://get.teamviewer.com/ezNetworkingHost'
    Invoke-WebRequest -Uri $ezRsUrl -OutFile "C:\ezNetworking\Automation\ezCloudDeploy\ezRsInstaller.exe"
    Start-Process -FilePath "C:\ezNetworking\Automation\ezCloudDeploy\ezRsInstaller.exe" -ArgumentList "/S" -Wait
}
catch {
    Write-Error " Zed says: ezRS is already installed or had an error $($_.Exception.Message)"
}

Stop-Transcript

$Time = Get-date -Format t
$Splat = @{
    Text = 'Zed: Default apps script finished' , "Installed Choco, ezRMM, ezRS. Finished $Time"
    Applogo = 'https://iili.io/H8B8JtI.png'
    Sound = 'IM'
}
New-BurntToastNotification @splat 

<#
.SYNOPSIS
Installes Chocolatey and minimal default packages and onboards the computer to ezRmm.

.DESCRIPTION
This script installs Chocolatey and minimal default packages. It reads the ezClientConfig.json and onboards the computer to ezRmm.

.NOTES
Author: Jurgen Verhelst | ez Networking | www.ez.be
#>