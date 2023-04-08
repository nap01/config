#!/usr/bin/env bash

# Import Enviroment Variables
set -a; source .env; set +a

# 1 - copy /media/"$USER"/usb/init to /home/"$USER"/init
sudo cp -r /media/"$USER"/usb/init /home/"$USER"/init
sudo chmod +x /home/"$USER"/init/init1.sh
sudo chmod +x /home/"$USER"/init/init2.sh
sudo chmod +x /home/"$USER"/init/init3.sh
sudo cat /home/"$USER"/init/sshd_config | sudo tee /etc/sshd_config

# add sshusers group
sudo addgroup sshusers

# add new user & give necessary permissions
sudo usermod -aG sshusers "$USER"

# create ~/.ssh & ~/.ssh/authorized_keys then add public key
sudo -H -u "$USER" bash -c 'mkdir ~/.ssh'
sudo -H -u "$USER" bash -c 'touch ~/.ssh/authorized_keys'
sudo cat ~/init/id_ed25519.pub | sudo tee -a ~/.ssh/authorized_keys

# apt update, upgrade, autoremove, and clean
sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt clean

# install dev essentials: mosh, tmux, git, git-lfs, nvim, cmake
sudo apt install -y mosh tmux git git-lfs neovim cmake

# final script cleanup
sudo apt autoremove && sudo apt clean

# start init2.sh
cd /home/"$USER" || exit
./init2.sh
