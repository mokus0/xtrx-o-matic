#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

builds_dirs=( ../../builds ../../builds.in-dev )
source build-scripts/base-functions.sh

builds=( "$@" )

deps=()

apt_build_dependencies() {
    deps+=( "$@" )
}

apt_dependencies() {
    deps+=( "$@" )
}

git_repository() {
    apt_build_dependencies git
}

cmake_build() {
    apt_build_dependencies cmake
}

cmake_build_subdir() {
    apt_build_dependencies cmake
}

for builds_dir in "${builds_dirs[@]}"; do
    for build in "$builds_dir"/*.build; do
        if [[ -f "$build" ]]; then
            source "$build"
        fi
    done
done

format_deps() {
    for dep in "$@"; do
        echo "$dep"
    done | sort | uniq
}

# TODO: separate script for removing build-only dependencies
sudo apt-get install $(format_deps "${deps[@]}")
