# Fedora 37 Workstation Config Script

This is a procedure document and bash script to configure Fedora 37 Workstation.

## 0 – Environment Variables (a.k.a. Script Settings)

```bash
export HOSTNAME="fedora"
export USERNAME="nap01"
export GITHUB_USERNAME="nap01" 
export BACKUP=/run/media/$USER/[NAME_OR_UUID_BACKUP_DRIVE]/@home/$USER/
```

## 1 – system tweaks

### 1.1 – Security //TODO

#### 1.1.1 – SSH Public/Private Keys

```bash
ssh-keygen -t ed25519 -c "$USERNAME@$HOSTNAME - Primary Key"
```

#### 1.1.2 – Create SSH Group For AllowGroups option in /etc/ssh/sshd_config

```bash
sudo groupadd sshusers

sudo usermod -a -G sshusers $USERNAME
```

#### 1.1.3 – Secure /etc/ssh/sshd_config

First, backup current `/etc/ssh/sshd_config` state:

```bash
sudo cp --archive /etc/ssh/sshd_config /etc/ssh/sshd_config-COPY-$(date +"%Y%m%d%H%M%S")
sudo sed -i -r -e '/^#|^$/ d' /etc/ssh/sshd_config
```

Add the following to `etc/ssh/sshd_config` and then edit as neccessary:

```bash
########################################################################################################
# start settings from https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67 as of 2019-01-01
########################################################################################################

# Supported HostKey algorithms by order of preference.
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key

KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256

Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com

# LogLevel VERBOSE logs user's key fingerprint on login. Needed to have a clear audit track of which key was using to log in.
LogLevel VERBOSE

# Use kernel sandbox mechanisms where possible in unprivileged processes
# Systrace on OpenBSD, Seccomp on Linux, seatbelt on MacOSX/Darwin, rlimit elsewhere.
# Note: This setting is deprecated in OpenSSH 7.5 (https://www.openssh.com/txt/release-7.5)
# UsePrivilegeSeparation sandbox

########################################################################################################
# end settings from https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67 as of 2019-01-01
########################################################################################################

# don't let users set environment variables
PermitUserEnvironment no

# Log sftp level file access (read/write/etc.) that would not be easily logged otherwise.
Subsystem sftp  internal-sftp -f AUTHPRIV -l INFO

# only use the newer, more secure protocol
Protocol 2

# disable X11 forwarding as X11 is very insecure
# you really shouldn't be running X on a server anyway
X11Forwarding no

# disable port forwarding
AllowTcpForwarding no
AllowStreamLocalForwarding no
GatewayPorts no
PermitTunnel no

# don't allow login if the account has an empty password
PermitEmptyPasswords no

# ignore .rhosts and .shosts
IgnoreRhosts yes

# verify hostname matches IP
UseDNS yes

Compression no
TCPKeepAlive no
AllowAgentForwarding no
PermitRootLogin no

# don't allow .rhosts or /etc/hosts.equiv
HostbasedAuthentication no

# limit use of ssh to sshusers group
AllowGroups sshusers
```

#### 1.1.4 –  Remove Short Diffie-Hellman Keys

Per Mozilla's [OpenSSH guidelines for OpenSSH 6.7+](https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67), "all Diffie-Hellman moduli in use should be at least 3072-bit-long".

Make a backup of SSH's moduli file /etc/ssh/moduli:

```bash
sudo cp --archive /etc/ssh/moduli /etc/ssh/moduli-COPY-$(date +"%Y%m%d%H%M%S")
```

Remove short moduli:

```bash
sudo awk '$5 >= 3071' /etc/ssh/moduli | sudo tee /etc/ssh/moduli.tmp
sudo mv /etc/ssh/moduli.tmp /etc/ssh/moduli
```

#### 1.1.5 – Limit Who Can Use su



Create a group:

```bash
sudo groupadd suusers
```

Add account(s) to the group:

```bash
sudo usermod -a -G suusers user1
```

```bash

```

#### 1.1.6 – Install/Configure UFW (firewall)



##### 1.1.6.1 – Install ufw:

```bash
sudo dnf install -y ufw
```

##### 1.1.6.2 – Deny all outgoing traffic:

```bash
sudo ufw default deny outgoing comment 'deny all outgoing traffic'
```
##### 1.1.6.2B ALTERNATIVE – Allow all outgoing treffic:

If you are not as paranoid as me, and don't want to deny all outgoing traffic, you can allow it instead:

```bash
sudo ufw default allow outgoing comment 'allow all outgoing traffic'
```

##### 1.1.6.3 – Deny all incoming traffic:

```bash
sudo ufw default deny incoming comment 'deny all incoming traffic'
```

##### 1.1.6.4 – Obviously we want SSH connections in:

```bash
sudo ufw limit in ssh comment 'allow SSH connections in'
```

##### 1.1.6.5 – Allow additional traffic as per your needs.

Some common use-cases:

```bash
# allow traffic out on port 53 -- DNS
sudo ufw allow out 53 comment 'allow DNS calls out'

# allow traffic out on port 123 -- NTP
sudo ufw allow out 123 comment 'allow NTP out'

# allow traffic out for HTTP, HTTPS, or FTP
# apt might needs these depending on which sources you're using
sudo ufw allow out http comment 'allow HTTP traffic out'
sudo ufw allow out https comment 'allow HTTPS traffic out'
sudo ufw allow out ftp comment 'allow FTP traffic out'

# allow whois
sudo ufw allow out whois comment 'allow whois'

# allow traffic out on port 68 -- the DHCP client
# you only need this if you're using DHCP
sudo ufw allow out 67 comment 'allow the DHCP client to update'
sudo ufw allow out 68 comment 'allow the DHCP client to update'
```

*Note: You'll **need** to allow HTTP/HTTPS for installing packages and many other things.*

##### 1.1.6.6 – Start ufw:

```bash
sudo ufw enable
```
##### 1.1.6.7 – Check ufw status
```bash
sudo ufw status verbose
```

### 1.2 – label start of user additions to ~/.bashrc

```bash
echo "" && echo '##### start of user additions #####' >> ~/.bashrc
```

### 1.3 – turn off dnf-makecache.timer

This module periodically updates metadata in the background to speed up the runtime of dnf commands.

Turn it off to avoid unnecessary bandwidth use at bad times.

```bash
systemctl disable dnf-makecache.timer
```

### 1.4 – speed up dnf

```bash
echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
cat /etc/dnf/dnf.conf
```

## 2 – Graphics

### 2.1 – Wayland or Xorg
The default in Fedora 37 Workstation is Wayland, edit `/etc/gd/custom.conf` and ensure the following settings are present in order to enable Xorg as the new default:

```bash
sudo nano /etc/gdm/custom.conf
# [daemon]
# WaylandEnable=false
# DefaultSession=gnome-xorg.desktop
```

### 2.2 – nvidia

If you have an nvida graphics card, uncomment and run the following:

```bash
#modinfo -F version nvidia
#sudo dnf update -y # and reboot if you are not on the latest kernel
#sudo dnf install -y akmod-nvidia # rhel/centos users can use kmod-nvidia instead
#sudo dnf install -y xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support
#sudo dnf install -y xorg-x11-drv-nvidia-cuda-libs
#sudo dnf install -y vdpauinfo libva-vdpau-driver libva-utils
#sudo dnf install -y vulkan
#modinfo -F version nvidia
```

## 3 – set hostname

The following sets the hostname of the system:

```bash
hostnamectl set-hostname $HOSTNAME
```

## 4 – check locales

If things look wrong, see the help file on the two commands or change locales and timezone in Gnome-Settings.

```bash
localectl status
timedatectl
```

## 5 – btrfs filesystem optimizations

Fedora has not optimized the mount options for btrfs yet. I have found that there is some general agreement on the following mount options if you are on a SSD or NVME:

- ssd: use SSD specific options for optimal use on SSD and NVME
- noatime: prevent frequent disk writes by instructing the Linux kernel not to store the last access time of files and folders
- space_cache: allows btrfs to store free space cache on the disk to make caching of a block group much quicker
- commit=120: time interval in which data is written to the filesystem (value of 120 is taken from Manjaro’s minimal iso)
- compress=zstd: allows to specify the compression algorithm which we want to use. btrfs provides lzo, zstd and zlib compression algorithms. Based on some Phoronix test cases, zstd seems to be the better performing candidate.
- discard=async: Btrfs Async Discard Support Looks To Be Ready For Linux 5.6

So add these options to your btrfs subvolume mount points in your fstab:

```bash
sudo nano /etc/fstab
# UUID=47faf958-b80a-43e1-a36f-ca5a932474f7 /                       btrfs   subvol=root,x-systemd.device-timeout=0,ssd,noatime,space_cache=v2,commit=120,compress=zstd,discard=async 0 0
# UUID=04ae92cd-717c-4aaf-bb24-58001be8d334 /boot                   ext4    defaults        1 2
# UUID=C17B-722D                            /boot/efi               vfat    umask=0077,shortname=winnt 0 2
# UUID=47faf958-b80a-43e1-a36f-ca5a932474f7 /home                   btrfs   subvol=home,x-systemd.device-timeout=0,ssd,noatime,space_cache=v2,commit=120,compress=zstd,discard=async 0 0
# UUID=47faf958-b80a-43e1-a36f-ca5a932474f7 /btrfs_pool             btrfs   subvolid=5,x-systemd.device-timeout=0,ssd,noatime,space_cache=v2,commit=120,compress=zstd,discard=async 0 0
```

```bash
sudo mkdir -p /btrfs_pool
sudo mount -a
```

Note that I also add a mountpoint for the btrfs root filesystem (this has always id 5) for easy access of all my subvolumes in /btrfs_pool.

You would need to restart to make use of the new options.

I usually first run updates and restart prior to restoring my backups, such that my restored files are using the optimized mount options such as compression.

Furthermore, as I am using btrfs discard support, let’s check whether the discard option is passed on in /etc/crypttab (as I am using LUKS to encrypt my drives):

```bash
sudo nano /etc/crypttab
# luks-fcc669e7-32d5-43b2-ba03-2db6a7f5b33d UUID=fcc669e7-32d5-43b2-ba03-2db6a7f5b33d none discard
```

As both fstrim and discard=async mount option can peacefully co-exist, I also enable fstrim.timer:

```bash
sudo systemctl enable fstrim.timer
```

## 6 – Install updates and reboot

```bash
sudo dnf upgrade --refresh
sudo dnf check
sudo dnf autoremove
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update
sudo reboot now
```

## 7 – Gnome Extensions and Tweaks

Install the extensions app, Gnome Tweaks, and some extensions:

```bash
sudo dnf install -y gnome-extensions-app gnome-tweaks
sudo dnf install -y gnome-shell-extension-appindicator
```

In Gnome Tweaks make the following changes:

- Disable “Suspend when laptop lid is closed” in General
- Disable “Activities Overview Hot Corner” in Top Bar
- Enable “Weekday” and “Date” in “Top Bar”
- Enable Battery Percentage (also possible in Gnome Settings - Power)
- Check Autostart programs

## 8 – Pop theme

I love the experience and theming of Gnome in Pop!_OS, so I make Fedora look and behave similarly.

### 8.1 – Install Pop-Shell Tiling Extension

```bash
sudo dnf install -y gnome-shell-extension-pop-shell
reboot
```

Reboot (or just logout/login), then activate it in the Extensions App (I usually don’t activate Native Window Placement) and you get an icon in your system tray.

Turn on Tiling by clicking on the icon.

Note that this will overwrite several Keyboard shortcuts, which is for me a good thing as I am quite used to the shortcuts in Pop!_OS.

If you want to be able to view these shortcuts in the icon in the tray, run the following:

### 8.2 – Pop shell keyboard shortcuts

```bash
sudo dnf install -y make cargo rust gtk3-devel
git clone https://github.com/pop-os/shell-shortcuts /home/$USER/fedora/pop-theme/shell-shortcuts
cd /home/$USER/fedora/pop-theme/shell-shortcuts
make
sudo make install
pop-shell-shortcuts
```

### 8.3 – Pop GTK theme

The following installs the Pop!_OS GTK theme:

```bash
sudo dnf install -y sassc meson glib2-devel
git clone https://github.com/pop-os/gtk-theme /home/$USER/fedora/pop-theme/gtk-theme
cd /home/$USER/fedora/pop-theme/gtk-theme
meson build && cd build
ninja
sudo ninja install
```

```bash
gsettings set org.gnome.desktop.interface gtk-theme "Pop"
```

### 8.4 – Pop icon theme

The following installs the Pop!_OS icon theme:

```bash
git clone https://github.com/pop-os/icon-theme /home/$USER/fedora/pop-theme/icon-theme
cd /home/$USER/fedora/pop-theme/icon-theme
meson build
sudo ninja -C "build" install
```

```bash
gsettings set org.gnome.desktop.interface icon-theme "Pop"
gsettings set org.gnome.desktop.interface cursor-theme "Pop"
```

### 8.5 – Pop fonts

For fonts, install via dnf

```bash
sudo dnf install -y fira-code-fonts 'mozilla-fira*' 'google-roboto*'
```

Then go into Gnome Tweaks and make the following changes in Fonts:

- Interface Text: Fira Sans Book 10
- Document Text: Roboto Slab Regular 11
- Monospace Text: Fira Mono Regular 11
- Legacy Window Titles: Fira Sans SemiBold 10
- Hinting: Slight
- Antialiasing: Standard (greyscale)
- Scaling Factor: 1.00

### 8.6 – Pop Gnome Terminal Theme

Open gnome-terminal, go to Preferences and change the Theme variant to Default in the Global tab.

Then create a new Profile called Pop with the following settings:

- Text
  - Custom font: Fira Mono 12
  - Deactivate Terminal bell
- Colors
  - Deactivate Use colors from system theme
  - Built-in schemes: Custom
  - Default color: Text #F2F2F2 | Background: #333333
  - Bold color (unchecked) #73C48F
  - Cursor color (checked): Text #49B9C7 | Background: #F6F6F6
  - Highlight color (checked): Text #FFFFFF | Background: #48B9C7
  - Uncheck Transparend background
  - Palette colors:
    - 0: #333333 1: #CC0000 2: #4E9A06 3: #C4A000 4: #3465A4 5: #75507B 6: #06989A 7: #D3D7CF
    - 8: #88807C 9: #F15D22 10: #73C48F 11: #FFCE51 12: #48B9C7 13: #AD7FA8 14: #34E2E2 15: #EEEEEC
  - Uncheck Show bold text in bright colors

Right click on the Pop profile and set as default.

Lastly, we need to append some things to PS1 in our .bashrc to get the green prompt and some other neat colors in the terminal.

Mine looks like this:

```bash
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
 . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
 # We have color support; assume it's compliant with Ecma-48
 # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
 # a case would tend to support setf rather than setaf.)
 color_prompt=yes
    else
 color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
```

## 9 – Repos, languages, libraries, version managers, etc

### 9.1 – Additional Repositories

Enable third party repositories by going into Software -> Software Repositories -> Third Party Repositories -> Enable All.

Go through the list and enable all the repositories I think I need such as RPM Fusion NVIDIA Driver.

Then run:

```bash
sudo dnf install -y  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

#### 9.1.1 – To enable the RPM Fusion free and nonfree repositories, run

```bash
sudo dnf upgrade --refresh
sudo dnf groupupdate core
sudo dnf install -y rpmfusion-free-release-tainted
sudo dnf install -y dnf-plugins-core
```

Checkout `sudo dnf grouplist -v` to see available groups you might be interested in.

#### 9.1.2 – Flatpak support

Flatpak is installed by default on Fedora Workstation, but one needs to enable the Flathub store:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update
```

#### 9.1.3 – Snap support

Enabling snap support boils down to running the following commands:

```bash
sudo dnf install -y snapd
sudo ln -s /var/lib/snapd/snap /snap # for classic snap support
sudo reboot now
```

## 10 – Restore from Backup

I mount my LUKS encrypted backup storage drive using nautilus (simply click on it in the file manager).

Then let’s use rsync to copy over my files and important configuration scripts:

```bash
# this environment variable is replaced by the one at the start of the config
#export BACKUP=/run/media/$USER/NAME_OR_UUID_BACKUP_DRIVE/@home/$USER/
sudo rsync -avuP $BACKUP/Desktop ~/
sudo rsync -avuP $BACKUP/Documents ~/
sudo rsync -avuP $BACKUP/Downloads ~/
sudo rsync -avuP $BACKUP/Music ~/
sudo rsync -avuP $BACKUP/Pictures ~/
sudo rsync -avuP $BACKUP/Templates ~/
sudo rsync -avuP $BACKUP/Videos ~/
sudo rsync -avuP $BACKUP/.ssh ~/
sudo rsync -avuP $BACKUP/.gnupg ~/

sudo rsync -avuP $BACKUP/.local/share/applications ~/.local/share/
sudo rsync -avuP $BACKUP/.gitconfig ~/
sudo rsync -avuP $BACKUP/.gitkraken ~/
sudo rsync -avuP $BACKUP/.config/Nextcloud ~/.config/

sudo rsync -avuP $BACKUP/dynare ~/
sudo rsync -avuP $BACKUP/.dynare ~/
sudo rsync -avuP $BACKUP/Images ~/
sudo rsync -avuP $BACKUP/SofortUpload ~/
sudo rsync -avuP $BACKUP/Work ~/
sudo rsync -avuP $BACKUP/Zotero ~/
sudo rsync -avuP $BACKUP/MATLAB ~/
sudo rsync -avuP $BACKUP/.matlab ~/

sudo chown -R $USER:$USER /home/$USER # make sure I own everything
```

## 11 – SSH keys

If I want to create a new SSH key, I run e.g.:

```bash
ssh-keygen -t ed25519 -C "fedora-on-$HOSTNAME"
```

Usually, however, I restore my .ssh folder from my backup (see above).

Either way, afterwards, one needs to add the file containing your key, usually id_rsa or id_ed25519, to the ssh-agent:

```bash
eval "$(ssh-agent -s)" #works in bash
eval (ssh-agent -c) #works in fish
ssh-add ~/.ssh/id_ed25519
```

Don’t forget to add your public key to GitHub, Gitlab, Servers, etc.

## 12 – Codecs and Libraries

This one is needed to watch youtube videos

```bash
sudo dnf install ffmpeg-libs 
```

## 13 – Apps //TODO

### 13.1 – CLI

#### 13.1.1 – starship (via dnf) - shell prompt customization

#### 13.1.2 – tldr.sh (via npm) - shorter man pages

#### 13.1.3 – thefuck (via pip) - command corrector

#### 13.1.4 – fzf (via dnf) - fuzzy finder

### 13.2 – Browser

#### 13.2.1 – Firefox

I used to use Firefox for almost all of my browsing which is installed by default with the following:

- Extensions
  - Bitwarden
  - Disable HTML5 Autoplay
  - GNOME Shell-Integration
  - HTTPS Everywhere
  - uBlock Origin
- Plugins
  - OpenH264-Videocodec
  - Widevine Content Decryption Module
- Theme: firefox-gnome-theme:

```bash
git clone https://github.com/rafaelmardojai/firefox-gnome-theme/ /home/$USER/fedora/firefox-gnome-theme
cd /home/$USER/fedora/firefox-gnome-theme
./scripts/install.sh
```

#### 13.2.2 – Google Chrome

If I ever need Google Chrome, then I enable the repo in the software manager and install it via the software shop.
Profile

#### 13.2.3 – Profile-sync-daemon

This neat little utility improves your browsing experience:

```bash
sudo dnf install -y profile-sync-daemon
psd
# First time running psd so please edit /home/$USER/.config/psd/psd.conf to your liking and run again
nano /home/$USER/.config/psd/psd.conf
# Close your browser now
systemctl --user enable psd.service
systemctl --user start psd.service
systemctl --user status psd.service
psd preview
```

### 13.3 – System utilities

#### 13.3.1 – Flatseal

Flatseal is a great tool to check or change the permissions of your flatpaks:

```bash
flatpak install -y flatseal
```

#### 13.3.2 – Timeshift //TODO
[FIller Text]

#### 13.3.3 – Virtual machines: Quickemu and other stuff

Fedora by default has KVM, Qemu, virt-manager and gnome-boxes set up; however, I have found a much easier tool for most virtualization tasks: Quickqemu, a wrapper for Qemu that we will load into our path to ab able to run it's scripts anywhere:

```bash
git clone --filter=blob:none https://github.com/wimpysworld/quickemu /home/$USER/fedora/quickemu
cd /home/$USER/fedora/quickemu

sudo dnf install qemu bash coreutils edk2-tools grep jq lsb procps python3 genisoimage usbutils util-linux sed spice-gtk-tools swtpm wget xdg-user-dirs xrandr unzip

mkdir -p /home/$USER/.local/bin
ln -s /home/$USER/fedora/quickemu/quickemu /home/$USER/.local/bin/quickemu
```

I keep the conf files for my virtual machines on an external SSD.

### 13.4 – Networking

#### 13.4.1 – Dropbox

Unfortunately, I still have some use case for Dropbox:

```bash
sudo dnf install -y dropbox nautilus-dropbox
```

Open dropbox and set it up, check options.

#### 13.4.2 – Nextcloud

I have all my files synced to my own Nextcloud server, so I need the sync client:

```bash
sudo dnf install -y nextcloud-client nextcloud-client-nautilus
```

Open Nextcloud and set it up. Recheck options and note to ignore hidden files once the first folder sync is set up.

I get two annoying issues with Nextcloud, which will probably be fixed in the future. For now the following works for me:

If you have many subfolders (which I do), there are not enough inotify-watches and Nextcloud does not sync instantaneously but only periodically.

This can be solved by:

```bash
sudo -i
echo 'fs.inotify.max_user_watches = 524288' >> /etc/sysctl.conf
sysctl -p
```

The same issue happens with Visual Studio Code and the aforementioned workaround is taken from their instructions page (<https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc>).

If you use X11 instead of Wayland, the app indicator icon does not show if I enable autostart of Nextcloud in its settings menu.

The problem is, that while the nextcloud client is actually running after being autostarted, there is no tray icon (I use the ‘KStatusNotifierItem/AppIndicator Support’ extension). Whereas, if I start the client manually after logging in (without autostart or after killing the autostarted instance), the icon is there.

For anyone experiencing this issue the workaround is to delay the autostart.

That is, make the following changes to the .desktop file which resides in the subdirectory ~/.config/autostart of the users home directory:

```bash
nano /home/$USER/.config/autostart/com.nextcloud.desktopclient.nextcloud.desktop 
# [Desktop Entry]
# Categories=Utility;X-SuSE-SyncUtility;
# Type=Application
# Exec=bash -c 'sleep 5 && nextcloud'
# Name=Nextcloud desktop sync client
# Comment=Nextcloud desktop synchronization client
# GenericName=Folder Sync
# Icon=Nextcloud
# Keywords=Nextcloud;syncing;file;sharing;
# X-GNOME-Autostart-Delay=3
```

What it does is simply waiting 3+5 seconds before launching the client.

Your mileage may vary - perhaps you need to give it more time if your startup takes longer than mine.

Alternatively, you might install TopIcons Plus Gnome Extension in addition to the KStatusNotifierItem/AppIndicator Support Extension.

I set the ‘Icon size’ to 18 in the settings of TopIcons Plus, the ‘Tray horizontal alignment’ to ‘Right’ and ‘Tray offset’ to 1, see also Mattermost.

#### 13.4.3 – OpenConnect and OpenVPN

```bash
sudo dnf install -y openconnect NetworkManager-openconnect NetworkManager-openconnect-gnome
sudo dnf install -y openvpn NetworkManager-openvpn NetworkManager-openvpn-gnome
```

Go to Settings-Network-VPN and add openconnect for my university VPN and openvpn for ProtonVPN, check connections.

#### 13.4.4 – Remote desktop

To access a remote Windows desktop session:

```bash
sudo dnf install -y rdesktop
echo "rdesktop -g 1680x900 wiwi-farm.uni-muenster.de -r disk:home=/home/$USER/ -u "WIWI\w_muts01" &" > ~/wiwi.sh
chmod +x wiwi.sh
cat <<EOF > ~/.local/share/applications/wiwi.desktop
[Desktop Entry]
Name=WIWI Terminal Server
Comment=WIWI Terminal Server wiwi-farm
Keywords=WIWI;RDP;
Exec=/home/$USER/wiwi.sh
Icon=preferences-desktop-remote-desktop
Terminal=false
MimeType=application/x-remote-connection;x-scheme-handler/vnc;
Type=Application
StartupNotify=true
Categories=Network;RemoteAccess;
EOF
```

Note that this also adds a shortcut to the menu.

#### 13.4.5 – Torrent - Transmission

```bash
sudo dnf -y install transmission
```

### 13.5 – Coding

#### 13.5.1 – git, git-lfs, and gitkraken

git and git-lfs are very useful tools for me; as a GUI I have been experimenting with GitKraken:

```bash
sudo dnf install -y git git-lfs
git-lfs install
flatpak install -y gitkraken
```

The flatpak version of GitKraken works perfectly.

Open GitKraken and set up Accounts and Settings (or restore from Backup see above).

Note that for the flatpak version, one needs to add the following Custom Terminal Command: `flatpak-spawn --host gnome-terminal %d` to be able to open the repository quickly in the terminal.

#### 13.5.2 – rtx/asdf - 'universal' version manager

asdf is a 'universal' tool version manager. rtx is a wrapper for asdf that fixes some of the quirks of asdf, primarily doing away with the use of "shims" and fixing some odd user interfaces choices.

It is similar to nvm (node version manager), but for many languages and/or tools.

```bash
dnf install curl git
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.1
```

##### 13.5.2B – OPTIONAL (already present in ~/.bashrc from chezmoi)

```bash
echo '# initialize asdf' >> ~/.bashrc && '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '# initialize asdf autocompletions' >> ~/.bashrc && '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc

```

I want to install chezmoi for dotfile management, python for pip/pipx, nodejs for npm, rust for cargo, and R (rlang) for rstudio/rmarkdown

First we install the dependencies, install/configure with asdf, and then set global version to latest.

##### 13.5.3 – Python

```bash
sudo dnf groupinstall "Development Tools"
sudo dnf install make gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-devel libnsl2-devel
asdf plugin add python && asdf install python latest && asdf global python latest
```

##### 13.5.4 – pipx

install and run isolated python environments for packages

```bash
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```

##### 13.5.5 – Nodejs

```bash
# python/pip is handled via asdf
#sudo dnf install python3 gcc-c++ make python3-pip
sudo dnf install gcc-c++ make
asdf plugin add nodejs && asdf install nodejs latest && asdf global nodejs latest
```

##### 13.5.6 – Rust (for cargo)

```bash
asdf plugin add rust && asdf install rust latest && asdf global rust latest
```

##### 13.5.7 – R (rlang -  rstudio/rmarkdown)

```bash
asdf plugin add rlang && asdf install rlang latest && asdf global rlang latest
sudo dnf install -y openblas
```

##### 13.5.8 – Java via Openjdk

Install the default OpenJDK Runtime Environment:

```bash
#asdf plugin add java #   optionally install java-asdf plugin 
sudo dnf install -y java-latest-openjdk
java -version
```

##### 13.5.9 – chezmoi - dotfile management

```bash
asdf plugin add chezmoi && asdf install chezmoi latest && asdf global chezmoi latest
#### one-liner
chezmoi init --apply https://github.com/$GITHUB_USERNAME/dotfiles.git

#### if you want to check the diff or edit before you apply
#chezmoi init https://github.com/$GITHUB_USERNAME/dotfiles.git
#chezmoi diff
#chezmoi edit $file 
#chezmoi apply -v
```

### 13.6 – Productivity

```bash
sudo snap install superproductivity
```

### 13.7 – Text-processing

#### 13.7.1 – RStudio

For teaching, data analysis, and advanced notetaking there is nothing better than R and RStudio:

```bash
sudo dnf install -y rstudio-desktop
```

Open rstudio, set it up to your liking.

##### 13.7.1.1 – Installing LaTex in RStudio

Luckily there is a very nice package that was created for the easy installation of LaTeX in RStudio!
    - Type `install.packages("tinytex")` into the Console and press return to run the code.
    - After that is complete, type `tinytex::install_tinytex()` into the Console and press return.

For some reason, even after a successful installation, sometimes it shows some error/warning messages at the end.

Ignore them and check whether it works as detailed below.

To check whether it was installed properly:

1. Go to File -> New File -> RMarkdown…
2. Then click PDF as the default output option. It will give you example text in the file.
3. Press the Knit button (with the yarn icon) and name the file whatever you want (Test is always a good option) and put it on your Desktop.
4. It may take a couple of minutes, but you should have a PDF with the same file name (Test.pdf for example) on your Desktop, if it works.
5. If it says Error: LaTeX failed to compile, that means the tinytex installation did not work. Make sure you ran both lines

#### 13.7.2 – Visual Studio Code

I am in the process of transitioning all my coding to Visual Studio code:

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install -y code
```

I sync my settings and extensions inside VScode. Similar to Nextcloud there is an error labeled “Visual Studio Code is unable to watch for file changes in this large workspace” (error ENOSPC) which has to do with the limit of inotify. The workaround (if you haven’t done so already) is to run:

```bash
sudo -i
echo 'fs.inotify.max_user_watches = 524288' >> /etc/sysctl.conf
sysctl -p
```

The same issue happens with Nextcloud.

#### 13.7.3 – Hugo

My website uses the Academic Template for Hugo, which is based on Go. As I need the extended version I don’t install hugo from the repo, but instead download the official release binary from Github:

```bash
sudo dnf install -y golang #dependency I need
```

```bash
export HUGOVER=`curl --silent "https://api.github.com/repos/gohugoio/hugo/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'`
wget https://github.com/gohugoio/hugo/releases/download/v${HUGOVER:1}/hugo_extended_${HUGOVER:1}_Linux-64bit.tar.gz
tar -xvf hugo_extended_${HUGOVER:1}_Linux-64bit.tar.gz hugo
rm hugo_extended_${HUGOVER:1}_Linux-64bit.tar.gz
mv hugo ~/.local/bin/hugo
hugo version
```

#### 13.7.4 – Latex related packages

I write all my papers and presentations with Latex using either TexStudio or VScode as editors:

```bash
sudo dnf install -y texlive-scheme-full
sudo dnf install -y texstudio
```

Open texstudio and set it up.

#### 13.7.5 – Microsoft Fonts

Sometimes I get documents which require fonts from Microsoft:

```bash
sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
```

#### 13.7.6 – Zotero

Zotero is great to keep track of the literature I use in my research and teaching. I install it via a flatpak:

```bash
flatpak install -y zotero
```

Open zotero, log in to account, install extension better-bibtex and sync.

### 13.8 – Communication

#### 13.8.1 – Mattermost

Mattermost, an open-source slack-alternative, can be installed via flatpak:

```bash
flatpak install -y Mattermost
```

Unfortunately, I still have an issue with the tray icon as it is only shown when turning the KStatusNotifierItem/AppIndicator Support Extension off and on again.

However, what works for me is to additionally install the TopIcons Plus Gnome Extension.

I set the ‘Icon size’ to 18 in the settings of TopIcons Plus, the ‘Tray horizontal alignment’ to ‘Right’ and ‘Tray offset’ to 1.

#### 13.8.2 – Zoom

Zoom can be installed either via snap or flatpak. I find the flatpak version works better with the system tray icons:

```bash
flatpak install -y zoom
```

Open zoom, log in and set up audio and video.

#### 13.8.3 – Signal

```bash
flatpak install org.signal.Signal
```

### 13.9 – Multimedia

#### 13.9.1 – VLC

One of the best and most extensible cross-platform video players:

```bash
sudo dnf install -y vlc
```

Open it and check whether it works.

#### 13.9.2 – Multimedia Codecs

If you have VLC installed, you should be fine as it has built-in support for all relevant audio and video codecs.

In other cases, I have found that the following commands install all required stuff for Audio and Video:

```bash
sudo dnf groupupdate sound-and-video
sudo dnf install -y libdvdcss
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg 
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
```

For OpenH264 in Firefox I run:

```bash
sudo dnf config-manager --set-enabled fedora-cisco-openh264
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264
```

Afterwards you need to open Firefox, go to menu → Add-ons → Plugins and enable OpenH264 plugin.
You can do a simple test whether your H.264 works in RTC on this page (check Require H.264 video).

#### 13.9.3 – OBS

I like that the snap version has all popular extensions included, so I use it:

```bash
sudo snap install obs-studio --edge
sudo snap connect obs-studio:audio-record
sudo snap connect obs-studio:avahi-control
sudo snap connect obs-studio:camera
sudo snap connect obs-studio:jack1
sudo snap connect obs-studio:joystick
sudo snap connect obs-studio:removable-media
```

Open OBS and set it up, import your scenes, etc.

### 13.10 – Applications that still need instructions written //TODO

- xwmx/nb
- wustho/epr
- sunsations/SpeedRead
- xtyrrell/undollar
- mptre/yank
- 


- vscode
  - VSC-Essentials
  - Markdown
  - Bash
    - Shellman
    - Shellcheck
    - Shell Script Language Basics
    - shell-format
    - bash debug
    - indent-rainbow

## 14 – Gnome Settings

- Set up Wifi, Ethernet and VPN
- Turn off bluetooth
- Change wallpaper
- Automatically delete recent files and trash
- Turn of screen after 15 min
- Turn on night mode
- Add online account for Nextcloud and Fedora
- Deactivate system sounds, mute mic
- Turn of suspend, shutdown for power button
- Turn on natural scrolling for mouse touchpad
- Go through keyboard shortcuts and adapt, I also add custom ones:
  - xkill on CTRL+ALT+X
  - gnome-terminal on CTRL+ALT+T
- Change clock to 24h format
- Display battery as percentage
- Check your default programs

## 15 – Other stuff

- Bookmarks for netdrives: Using CTRL+L in nautilus, I can open the following links inside nautilus and add bookmarks to these drives for easy access:
- university netdrive: <davs://w_muts01@wiwi-webdav.uni-muenster.de/>
- university cluster: <sftp://w_muts01@palma2c.uni-muenster.de>
- personal homepage: <sftp://mutschler.eu>
- Reorder Favorites: I like to reorder the favorites on the gnome launcher (when one hits the SUPER) key
- Go through all programs: Hit META+A and go through all programs, decide whether you need them or uninstall these
- Check autostart programs in Gnome Tweaks
- In the file manager preferences I enable “Sort folders before files
- Click on the clock and set the location for your weather forecast.
