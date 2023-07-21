#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x
set -e
set -u

# Install rust

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

cargo --version
rustc --version
rustup --version

