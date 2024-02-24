#!/usr/bin/env sh
#
set -eu

for template in "$@"; do
    [ -f "$template" ] || continue
    set -x
    nix --extra-experimental-features "nix-command flakes" flake check --no-write-lock-file "./$template"
    set +x
done
