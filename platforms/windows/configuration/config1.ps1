# System
winget install Oracle.VirtualBox
winget install DiskInternals.LinuxReader

# Utility 
winget install AntibodySoftware.WizTree
winget install PeterBClements.QuickPar
winget install GiorgioTani.PeaZip
winget install jbreland.uniextract
winget install CrystalRich.LockHunter
winget install CodeSector.TeraCopy
winget install WinMerge.WinMerge
winget install ShareX.ShareX
winget install Adobe.Acrobat.Reader.64-bit

# Network
winget install qBittorrent.qBittorrent
winget install OpenVPNTechnologies.OpenVPN
winget install WinSCP.WinSCP

# Windows and CLI
winget install CLechasseur.PathCopyCopy
winget install Microsoft.PowerToys # https://github.com/microsoft/PowerToys
winget install Microsoft.WindowsTerminal
winget install Microsoft.PowerShell
winget install JanDeDobbeleer.OhMyPosh

# Git
winget install Git.Git
winget install GitHub.cli
winget install GitHub.GitHubDesktop

# Development Enviroment
winget install Docker.DockerDesktop
winget install Microsoft.dotnet
winget install Rustlang.Rust.GNU
winget install Yarn.Yarn
# Not needed because of fnm
## winget install OpenJS.NodeJS

# IDE
winget install Microsoft.VisualStudioCode
winget install RStudio.RStudio.OpenSource
#winget install JetBrains.IntelliJIDEA.Community

# Productivity
winget install ActivityWatch.ActivityWatch
winget install splode.pomotroid
winget install Anki.Anki

# Browser
winget install eloston.ungoogled-chromium
winget install Google.Chrome
winget install Mozilla.Firefox
winget install PrestonN.FreeTube

# Chat
#winget install Discord.Discord
winget install OpenWhisperSystems.Signal

# Audio
## winget install File-New-Project.EarTrumpet
winget install VB-Audio.Voicemeeter.Potato
winget install Mp3tag.Mp3tag

# Video
winget install VideoLAN.VLC
winget install Streamlink.Streamlink

# Gaming
winget install Valve.Steam
winget install EpicGames.EpicGamesLauncher

# Cargo
cargo install fnm

# Manual Install
iwr -useb https://files.gpg4win.org/gpg4win-4.0.3.exe | iex 

# gpg4win
## Step 1: Download
$url = "http://www.contoso.com/pathtoexe.exe"
$outpath = "$PSScriptRoot/myexe.exe"
Invoke-WebRequest -Uri $url -OutFile $outpath

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $outpath)

## Step 2: Install
$args = @("Comma", "Separated", "Arguments")
Start-Process -Filepath "$PSScriptRoot/myexe.exe" -ArgumentList $args