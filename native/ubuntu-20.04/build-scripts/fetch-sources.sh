#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"/..

source build-scripts/base-functions.sh

git_repository() {
    banner "Fetch $BUILD_TARGET (git_repository $*)"

    repo=$1
    checkout=$2
    shift 2
    
    if [[ -d "$SOURCE_DIR" ]]; then
        (cd "$SOURCE_DIR" && git fetch origin)
    else
        git clone "$repo" "$SOURCE_DIR"
    fi
    
    (
        cd "$SOURCE_DIR"
        git config advice.detachedHead false
        git checkout "$checkout"
    )
}

git_fetch_submodules() {
    (
        cd "$SOURCE_DIR"
        git submodule update --init "$@"
    )
}

for build in "$@"; do
    source "$build"
done
