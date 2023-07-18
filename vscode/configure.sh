#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x
set -e
set -u

# Configure VSCode

## Install extensions

while read -r line; do
    code --install-extension "$line"
done < vscode/extensions.txt

## Configure settings

cp -f vscode/settings.json "$HOME/.config/Code/User/settings.json"

exit 0
