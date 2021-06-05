#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"/..

source /base-functions.sh

writes_to_src() {
    sudo chown -R peon "$SOURCE_DIR"
}

_cmake_build() {
    _build_dir=$1
    _source_dir=$2
    shift 2

    mkdir -p "$_build_dir"
    (
        cd "$_build_dir"
        
        banner "CONFIGURE $BUILD_TARGET"
        cmake "${CMAKE_GLOBAL_OPTS[@]}" "$_source_dir" "$@"
        
        banner "BUILD $BUILD_TARGET"
        make "${MAKE_GLOBAL_OPTS[@]}"
        
        banner "INSTALL $BUILD_TARGET"
        sudo make install
    )
}

cmake_build() {
    _cmake_build "$BUILD_DIR" "$SOURCE_DIR" "$@"
}

cmake_build_subdir() {
    _subdir="$1"
    shift

    _cmake_build "$BUILD_DIR/$_subdir" "$SOURCE_DIR/$_subdir" "$@"
}

for build in "$@"; do
    unset -f post_install
    source "$build"
    
    if type post_install &>/dev/null; then
        banner "POST INSTALL $BUILD_TARGET"
        ( post_install )
    fi
done
