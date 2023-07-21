#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x
set -e
set -u

# Retrieve dotfiles

## .config

mkdir -p .config

cp -R -f "$HOME/.config/autostart" .config
cp -f "$HOME/.config/yakuakerc" .config
cp -f "$HOME/.config/user-dirs.locale" .config
cp -f "$HOME/.config/user-dirs.dirs" .config

## .local

mkdir -p .local/share

cp -R -f "$HOME/.local/share/fonts" .local/share
cp -R -f "$HOME/.local/share/konsole" .local/share

cp -f "$HOME/.local/share/user-places.xbel" .local/share

## Others

# cp -R -f "$HOME/.bin" .
cp -R -f "$HOME/.tools" .

cp -f "$HOME/.p10k.zsh" .

cp -f "$HOME/.tmux.conf" .
cp -f "$HOME/.vimrc" .
cp -f "$HOME/.zshrc" .
cp -f "$HOME/.gitconfig" ./gitconfig

