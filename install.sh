#!/usr/bin/env bash
# -*- coding: utf-8 -*-

dirs=$(find . -mindepth 2 -type f -name "install.sh" | sed -r 's|/[^/]+$||' | sort | uniq)

for dir in $dirs; do
    echo "Installing $dir"
    . $dir/install.sh
    if [ -f $dir/config.sh ]; then
        echo "Configuring $dir"
        . $dir/config.sh
    fi
done
