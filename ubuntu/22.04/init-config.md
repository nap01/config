# Ubuntu 22.04 Config Script

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

##### 1.1.6.1 – Install ufw

```bash
sudo dnf install -y ufw
```

##### 1.1.6.2 – Deny all outgoing traffic

```bash
sudo ufw default deny outgoing comment 'deny all outgoing traffic'
```

##### 1.1.6.2B ALTERNATIVE – Allow all outgoing treffic

If you are not as paranoid as me, and don't want to deny all outgoing traffic, you can allow it instead:

```bash
sudo ufw default allow outgoing comment 'allow all outgoing traffic'
```

##### 1.1.6.3 – Deny all incoming traffic

```bash
sudo ufw default deny incoming comment 'deny all incoming traffic'
```

##### 1.1.6.4 – Obviously we want SSH connections in

```bash
sudo ufw limit in ssh comment 'allow SSH connections in'
```

##### 1.1.6.5 – Allow additional traffic as per your needs

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

##### 1.1.6.6 – Start ufw

```bash
sudo ufw enable
```

##### 1.1.6.7 – Check ufw status

```bash
sudo ufw status verbose
```
