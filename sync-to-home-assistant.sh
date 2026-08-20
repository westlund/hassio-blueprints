#!/bin/sh

set -eu

target=${1:-/homeassistant}
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

install -d "$target/blueprints/automation/papamike"
install -d "$target/blueprints/script/papamike"

for source in "$repo_dir"/blueprints/automation/papamike/*.yaml; do
  install -m 0644 "$source" "$target/blueprints/automation/papamike/"
done

for source in "$repo_dir"/blueprints/script/papamike/*.yaml; do
  install -m 0644 "$source" "$target/blueprints/script/papamike/"
done

echo "Blueprints synchronized to $target/blueprints"
