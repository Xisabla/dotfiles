#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x
set -e
set -u

# Update and upgrade

sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Install base packages

sudo apt install -y $(cat base/packages.txt)

# Clean up

sudo apt autoremove -y

# Install oh-my-zsh

[[ ! -d "$HOME/.oh-my-zsh" ]] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zsh plugins and themes

[[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
[[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]        && git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
[[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete" ]]           && git clone https://github.com/marlonrichert/zsh-autocomplete "$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete"

[[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]               && git clone https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

# Install .fzf

[[ ! -d "$HOME/.fzf" ]]                                                 && git clone https://github.com/junegunn/fzf.git "$HOME/.fzf"

exit 0
