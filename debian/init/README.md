# Debian Init Script

For all the commands in the 0 section you will need to replace the variables manually before you run them.

```bash
$DEV = /dev/sdb1 
```

DEV should be the device and partition the init folder is located on, typically a USB drive or SD card.

```bash
$USER = username
```

USER is an existing user that has sudo permissions, ideally the user you intend to use daily

## 0.2 - Mount DEV to /media/USER/usb

```bash
sudo mount /dev/sda1 /media/$USER/usb
```

## 0.3 - Move init-prep.sh to user home

```bash
sudo mv /media/$USER/usb/init/init-prep.sh /home/$USER/init-prep.sh
```

## 0.4 - Run init-prep.sh

```bash
sudo chmod +x /home/$USER/init-prep.sh
./prep.sh
```

## 2 - Run pi-init2.sh

Switch to created user and change directory to user home, then run the following script:

```bash
./pi-init2.sh
```

Complete docker installation via LMDS.

## 3 - Run pi-init3.sh

After running ./deploy.sh and configuring docker, run the following script:

```bash
./pi-init3.sh
```
