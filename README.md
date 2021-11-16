# dotfiles

```bash
cd ~

# Basics
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt install -y \
    build-essential \
    cmake \
    openssh-client \
    vim \
    zsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Dotfiles
git clone https://github.com/Xisabla/dotfiles

cd dotfiles && \
	git submodule update --init --recursive && \
    cd ../

cp dotfiles/.oh-my-zsh/ -R ~/
cp dotfiles/gitconfig ~/.gitconfig
cp dotfiles/.p10k.zsh ~/.
cp dotfiles/.vimrc ~/.
cp dotfiles/.zshrc ~/.

# WSL2 SSH Pagent (https://github.com/BlackReloaded/wsl2-ssh-pageant)
windows_destination="/mnt/c/Users/Public/Downloads/wsl2-ssh-pageant.exe"
linux_destination="$HOME/.ssh/wsl2-ssh-pageant.exe"
wget -O "$windows_destination" "https://github.com/BlackReloaded/wsl2-ssh-pageant/releases/latest/download/wsl2-ssh-pageant.exe" && \
    chmod +x "$windows_destination" && \
    ln -s $windows_destination $linux_destination

# Tools
mkdir ~/.bin
wget https://github.com/sharkdp/bat/releases/download/v0.18.3/bat-v0.18.3-aarch64-unknown-linux-gnu.tar.gz && \
    tar -xvzf bat-v0.18.3-aarch64-unknown-linux-gnu.tar.gz && \
    cp bat-v0.18.3-aarch64-unknown-linux-gnu/bat ~/.bin/bat && \
    chmod +x ~/.bin/bat && \
    rm -rf bat-v0.18.3-aarch64-unknown-linux-gnu.tar.gz bat-v0.18.3-aarch64-unknown-linux-gnu

mkdir ~/.tools
wget https://gist.githubusercontent.com/Xisabla/b1e01b32045ef47f681299fd1086b01d/raw/e63f319847b123e3fdaf2c8c67e933c3ad73d1a8/proxy.sh -O ~/.tools/proxy.sh

# Don't need sudo password
echo "`whoami`  ALL=(ALL)   NOPASSWD:ALL" | sudo tee /etc/sudoers.d/`whoami`
```
