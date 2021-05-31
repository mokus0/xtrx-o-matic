#!/bin/echo use the source, Luke!

CMAKE_GLOBAL_OPTS=(
    "-DCMAKE_INSTALL_PREFIX=$install_prefix"
    "-DCMAKE_INCLUDE_PATH=$install_prefix/include"
    "-DCMAKE_LIBRARY_PATH=$install_prefix/lib"
)

CORES=$(cat /proc/cpuinfo | egrep '^processor\s*:' | wc -l)

MAKE_GLOBAL_OPTS=(
    -j"$CORES"
)

build_submodule() {
    submodule=$1
    shift
    
    mkdir -p build/"$submodule"
    (
        cd build/"$submodule"
        cmake "${CMAKE_GLOBAL_OPTS[@]}" "$ext_dir"/"$submodule" "$@"
        make "${MAKE_GLOBAL_OPTS[@]}"
        sudo make install
    )
}

skip() {
	echo "skipping:" "$@"
}