#!/bin/bash

set -euo pipefail
shellcheck "$0"

script_dir=$(cd "$(dirname "$0")" && pwd)
ext_dir=$script_dir/ext

install_prefix=/opt/sdr

# YUCK. python can't handle "from gnuradio import blah" unless "blah" 
# is literally in the first gnuradio directory it finds.  So these files can't
# go into /opt with everything else.
gr_python_dir=/usr/lib/python2.7/dist-packages

git submodule update --init --recursive

CMAKE_GLOBAL_OPTS=(
    "-DCMAKE_INSTALL_PREFIX=$install_prefix"
    "-DCMAKE_INCLUDE_PATH=$install_prefix/include"
    "-DCMAKE_LIBRARY_PATH=$install_prefix/lib"
)

MAKE_GLOBAL_OPTS=(
    -j8
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

sudo apt-get install build-essential cmake libpython-dev python-numpy swig gnuradio gr-fosphor
build_submodule SoapySDR

sudo apt-get install gnuradio-dev
build_submodule gr-osmosdr "-DGR_PYTHON_DIR=$gr_python_dir"

# sudo apt-get install nvidia-opencl-dev opencl-headers libglfw3-dev
# build_submodule gr-fosphor "-DGR_PYTHON_DIR=$gr_python_dir" -DOPENCL_LIBRARY=/usr/lib/x86_64-linux-gnu/libOpenCL.so

build_submodule libusb3380
build_submodule xtrx_linux_pcie_drv
build_submodule liblms7002m
build_submodule libxtrxll
build_submodule libxtrxdsp
build_submodule libxtrx

build_submodule LimeSuite

sudo tee /etc/ld.so.conf.d/sdr-stuff.conf <<EOF
$install_prefix/lib
EOF
sudo ldconfig

# sudo dkms add xtrx_linux_pcie_drv/xtrx.dkms

# sudo tee /etc/udev/rules.d/50-xtrx.rules <<EOF
# KERNEL=="xtrx*", SUBSYSTEM=="xtrx", MODE="0666"
# EOF
# sudo udevadm control --reload-rules
# sudo udevadm trigger

(
    cd ext/LimeSuite/udev-rules
    sudo sh ./install.sh
    
    "$install_prefix/share/Lime/Desktop/install"
)