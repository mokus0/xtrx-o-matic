# Build descriptions are specified by calling shell functions.  These functions are defined here as no-ops,
# and then to allow the builds to run in a phased way, they are run with the functions substituted appropriately for each phase.

# Global build configurations, available in scope everywhere
install_prefix=/opt/sdr
gr_python_dir=/opt/sdr/python3.8/dist-packages

CMAKE_GLOBAL_OPTS=(
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_PREFIX=$install_prefix"
    "-DCMAKE_INCLUDE_PATH=$install_prefix/include"
    "-DCMAKE_LIBRARY_PATH=$install_prefix/lib"
)

CORES=$(cat /proc/cpuinfo | egrep '^processor\s*:' | wc -l)

MAKE_GLOBAL_OPTS=(
    -j"$CORES"
)

export GRC_BLOCKS_PATH=/opt/sdr/share/gnuradio/grc/blocks
export PKG_CONFIG_PATH=/opt/sdr/lib/pkgconfig
export PATH=/opt/sdr/bin:$PATH

native() {
    false
}

os() {
    if [[ "$#" -eq 1 ]]; then
        [[ "$1" = "ubuntu" || "$1" = "linux" ]]
    else
        [[ "$1" = "ubuntu" && "$2" = "20.04" ]]
    fi
}

source_dir() {
    echo -n "/src/$1"
}

build_dir() {
    echo -n "/build/$1"
}

# This MUST be the first function called when describing a build
build_target() {
    BUILD_TARGET="$1"
    SOURCE_DIR=$(source_dir "$1")
    BUILD_DIR=$(build_dir "$1")
}

# These may be called in any order after build_target and before one or more of the build commands.
git_repository() { :; }
apt_build_dependencies() { :; }
apt_dependencies() { :; }
writes_to_src() { :; }

# If used, this one must come _after_ git_repository
git_fetch_submodules() { :; }

# One or more build operations should end a build description section
cmake_build() { :; }
cmake_build_subdir() { :; }

# These functions can be used by build configs or worker scripts to report stuff on the console
banner() {
    echo "================================================================"
    echo "$@"
    echo "================================================================"
}

TODO() {
    echo "================================================================"
    echo "TODO:" "$@"
    echo "  in: " "${BASH_SOURCE[1]}"
    echo "================================================================"
}

fail() {
    banner "$@"
    exit 1
}
