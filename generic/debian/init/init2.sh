#!/usr/bin/env bash

# Import Enviroment Variables
set -a; source .env; set +a

# install nodejs & npm
sudo apt install nodejs
sudo apt install npm

# install python 3, pip, & pipx
sudo apt install python3
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# install rust
curl https://sh.rustup.rs -sSf | sh
sudo echo "# add cargo to $PATH"
source "$HOME/.cargo/env"

# install starship
cargo install starship --locked
sudo echo '# start starship' | sudo tee -a ~/.bashrc
sudo echo 'eval "$(starship init bash)"' | sudo tee -a ~/.bashrc

# install rtx-cli
cargo install cargo-binstall
cargo binstall rtx-cli
sudo echo '# start rtx-cli' | sudo tee -a ~/.bashrc
sudo echo 'eval "$(~/bin/rtx activate bash)"' | sudo tee -a ~/.bashrc

# install chezmoi
rtx install chezmoi@latest

# docker & LMDS stack
#git clone https://github.com/GreenFrogSB/LMDS.git /home/$USER/LMDS
#cd /home/$USER/LMDS || return
#./deploy.sh
## install docker & docker-compose via LMDS
## build full LMDS usenet stack with jellyfin (witout pi-hole or VPN)
