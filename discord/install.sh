#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x
set -e
set -u

# Install Discord

sudo apt update
sudo apt install -y libappindicator1 libc++1

wget "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb
sudo apt install -y ./discord.deb
rm discord.deb

timeout 1 discord

