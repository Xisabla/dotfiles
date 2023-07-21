#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x
set -e
set -u

# Retrieve settings.json

cp -f "$HOME/.config/Code/User/settings.json" vscode/settings.json

# Retrieve extensions

code --list-extensions | uniq | sort > vscode/extensions.txt

