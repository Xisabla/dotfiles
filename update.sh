#!/usr/bin/env bash
# -*- coding: utf-8 -*-

dirs=$(find . -mindepth 2 -type f -name "update.sh" | sed -r 's|/[^/]+$||' | sort | uniq)

for dir in $dirs; do
    echo "Updating $dir"
    . $dir/update.sh
done
