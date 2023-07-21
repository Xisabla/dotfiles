#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x
set -e
set -u

# Install Go

sudo apt update
sudo apt install -y tar wget

wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
rm go1.20.5.linux-amd64.tar.gz

[[ -d "/usr/local/go/bin" ]]                    && export PATH="$PATH:/usr/local/go/bin"
[[ -d "$HOME/go/bin" ]]                         && export PATH="$PATH:$HOME/go/bin"

go version

