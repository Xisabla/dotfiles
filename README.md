# dotfiles
## WSL

```bash
cd ~

# Basics
sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
sudo apt install -y \
	build-essential \
	cmake \
	zsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Dotfiles
git clone https://github.com/Xisabla/dotfiles

cd dotfiles && \
	git submodule update --init --recursive

cp dotfiles/.oh-my-zsh/ -R ~/
cp dotfiles/gitconfig ~/.gitconfig
cp dotfiles/.p10k.zsh ~/.
cp dotfiles/.vimrc ~/.
cp dotfiles/.zshrc ~/.

# Windows 10 WSL2 with VcXsrv
echo 'export DISPLAY=$(grep -oP "(?<=nameserver ).+" /etc/resolv.conf):0' >> ~/.zshrc
echo 'export LIBGL_ALWAYS_INDIRECT=1' >> ~/.zshrc

# Qt
sudo apt install qt5-default
```
