#!/bin/bash

# TODO: docker testing image
# TODO: github action to validate changes

set -e
set -u
set -x

# env & defaults
DEFAULT=${DEFAULT:-1}
#TODO: CONFIGURE=${CONFIGURE:-0}
DOTFILES_PATH=${DOTFILES_PATH:-$HOME/dotfiles}
DOTFILES_BRANCH=${DOTFILES_BRANCH:-main}
PERFORM_UPDATES=${PERFORM_UPDATES:-${DEFAULT}}

# install
INSTALL_SSH=${INSTALL_SSH:-${DEFAULT}}
INSTALL_TMUX=${INSTALL_TMUX:-${DEFAULT}}
INSTALL_VIM=${INSTALL_VIM:-${DEFAULT}}
INSTALL_ZSH=${INSTALL_ZSH:-${DEFAULT}}

# configure
CONFIGURE_GIT=${CONFIGURE_GIT:-${DEFAULT}}   # dotfiles git config
CONFIGURE_SSH=${CONFIGURE_SSH:-${DEFAULT}}   # dotfiles ssh config
CONFIGURE_TMUX=${CONFIGURE_TMUX:-${DEFAULT}} # dotfiles tmux config
CONFIGURE_VIM=${CONFIGURE_VIM:-${DEFAULT}}   # dotfiles vim config
CONFIGURE_ZSH=${CONFIGURE_ZSH:-${DEFAULT}}   # dotfiles zsh config

# additionnal install (non-standard)
INSTALL_BAT=${INSTALL_BAT:-${DEFAULT}} # https://github.com/sharkdp/bat
# TODO: INSTALL_GLOW
INSTALL_SHFMT=${INSTALL_SHFMT:-${DEFAULT}} # https://github.com/mvdan/sh

# tools
TOOL_PROXY=${TOOL_PROXY:-${DEFAULT}} # install proxy tool

# tweaks
TWEAK_NOTMUX=${TWEAK_NOTMUX:-${DEFAULT}}                 # add a user without auto tmux terminal
TWEAK_WSL_SSH_PAGENT=${TWEAK_WSL_SSH_PAGENT:-${DEFAULT}} # https://github.com/BlackReloaded/wsl2-ssh-pageant
TWEAK_SUDO=${TWEAK_SUDO:-${DEFAULT}}                     # disable sudo password prompt

# configuration prompts
# TODO

# base packages
packages=(
	"build-essential"
	"cmake"
	"git"
)

# item related packages
if [ "$INSTALL_BAT" = "1" ]; then packages+=("bat"); fi
if [ "$INSTALL_SSH" = "1" ]; then packages+=("openssh-client"); fi
if [ "$INSTALL_TMUX" = "1" ]; then packages+=("tmux"); fi
if [ "$INSTALL_VIM" = "1" ]; then packages+=("vim"); fi
if [ "$INSTALL_ZSH" = "1" ]; then packages+=("zsh"); fi

# install packages
if [ "$PERFORM_UPDATES" = "1" ]; then
	sudo apt update -y
	sudo apt upgrade -y
	sudo apt dist-upgrade -y
fi
sudo apt install -y "${packages[@]}"
sudo apt autoremove -y

# clone & checkout
git clone https://github.com/Xisabla/dotfiles ${DOTFILES_PATH}
wd=$(pwd)

cd ${DOTFILES_PATH}
git checkout ${DOTFILES_BRANCH}
git submodule update --init --recursive
cd ${wd}

# configure git
if [ "$CONFIGURE_GIT" = "1" ]; then
	cp ${DOTFILES_PATH}/gitconfig ${HOME}/.gitconfig
fi

# configure ssh
if [ "$CONFIGURE_SSH" = "1" ]; then
	cp -r ${DOTFILES_PATH}/.ssh ${HOME}/
fi

# configure tmux
if [ "$CONFIGURE_TMUX" = "1" ]; then
	cp ${DOTFILES_PATH}/.tmux.conf ${HOME}/
fi

# configure vim
if [ "$CONFIGURE_VIM" = "1" ]; then
	cp ${DOTFILES_PATH}/.vimrc ${HOME}/
fi

# configure zsh
if [ "$CONFIGURE_ZSH" = "1" ]; then
	yes n | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	cp -R ${DOTFILES_PATH}/.oh-my-zsh ${HOME}/
	cp ${DOTFILES_PATH}/.p10k.zsh ${HOME}/
	cp ${DOTFILES_PATH}/.zshrc ${HOME}/
	chsh -s $(which zsh)
fi

# additional stuff
if [ ! -d ${HOME}/.bin ]; then mkdir ${HOME}/.bin; fi

if [ "$INSTALL_BAT" = "1" ]; then
	ln -s $(which batcat) ${HOME}/.bin/bat
fi

if [ "$INSTALL_SHFMT" = "1" ]; then
	wget https://github.com/mvdan/sh/releases/download/v3.4.0/shfmt_v3.4.0_linux_amd64 -O ${HOME}/.bin/shfmt &&
		chmod +x ${HOME}/.bin/shfmt &&
		ln -s ${HOME}/.bin/shfmt ${HOME}/.bin/shellformat &&
		ln -s ${HOME}/.bin/shfmt ${HOME}/.bin/shell-format
fi

# tools
if [ ! -d ${HOME}/.tools ]; then mkdir ${HOME}/.tools; fi

if [ "$TOOL_PROXY" = "1" ]; then
	wget https://gist.githubusercontent.com/Xisabla/b1e01b32045ef47f681299fd1086b01d/raw/e63f319847b123e3fdaf2c8c67e933c3ad73d1a8/proxy.sh -O ${HOME}/.tools/proxy.sh
fi
