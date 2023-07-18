#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x
set -e
set -u

# Copy directories and files

cp -R -f .config "$HOME/.config"

cp -R -f .bin "$HOME/.bin"
cp -R -f .tools "$HOME/.tools"

cp -f .p10k.zsh "$HOME/.p10k.zsh"
cp -f .tmux.conf "$HOME/.tmux.conf"
cp -f .vimrc "$HOME/.vimrc"
cp -f .zshrc "$HOME/.zshrc"
cp -f gitconfig "$HOME/.gitconfig"

# Don't prompt for password when using sudo

echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/"$USER"

# Configure python alternatives

sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 2
sudo update-alternatives --auto python

exit 0
