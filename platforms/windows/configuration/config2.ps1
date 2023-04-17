# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install remaining programs not available via winget
choco install seatools -y
choco install ketarin -y
choco install sd-card-formatter -y
choco install etcher -y
choco install yumi -y
choco install yumi-uefi -y
choco install gimp -y
choco install photogimp -y
choco install gpodder -y
choco install eartrumpet -y
