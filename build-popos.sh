#!/bin/bash

set -euo pipefail
shellcheck -x "$0"

script_dir=$(cd "$(dirname "$0")" && pwd)
ext_dir=$script_dir/ext

install_prefix=/opt/sdr
xtrx_pcie_drv_version=0.0.1-2

# YUCK. python can't handle "from gnuradio import blah" unless "blah" 
# is literally in the first gnuradio directory it finds.  So these files can't
# go into /opt with everything else.
# 
# Also, big sad: gnuradio still needs python 2.7 (or at least the version in apt does)
gr_python_dir=/usr/lib/python2.7/dist-packages

sudo apt-get install gpsd gpsd-clients pps-tools dkms

# git submodule update --init --recursive

source functions.sh

sudo apt-get install build-essential libpython2-dev python-numpy swig gnuradio gr-fosphor
# sudo apt-get remove --purge cmake
# sudo snap install cmake --classic

build_submodule SoapySDR

# sudo apt-get install nvidia-opencl-dev opencl-headers libglfw3-dev
# build_submodule gr-fosphor "-DGR_PYTHON_DIR=$gr_python_dir" -DOPENCL_LIBRARY=/usr/lib/x86_64-linux-gnu/libOpenCL.so

sudo apt-get install libusb-1.0.0-dev python3-cheetah
build_submodule libusb3380
build_submodule xtrx_linux_pcie_drv
build_submodule liblms7002m
build_submodule libxtrxll
build_submodule libxtrxdsp
build_submodule libxtrx

build_submodule LimeSuite

sudo apt-get install libxml2-dev flex bison
build_submodule libiio
build_submodule libad9361-iio
build_submodule SoapyPlutoSDR

# CMAKE fails spuriously once
# see https://gitlab.kitware.com/cmake/cmake/issues/15829
build_submodule librtlsdr || build_submodule librtlsdr
sudo install -m 644 "$ext_dir"/librtlsdr/rtl-sdr.rules /etc/udev/rules.d/99-rtl-sdr.rules
sudo tee /lib/modprobe.d/blacklist-rtl28xxu.conf <<EOF
blacklist dvb_usb_rtl28xxu
EOF

build_submodule SoapyRTLSDR

build_submodule rx_tools

# TODO: fix. fails to build because of some CMAKE error.
skip sudo apt-get install gnuradio-dev
skip build_submodule gr-osmosdr "-DGR_PYTHON_DIR=$gr_python_dir"

# TODO: requires gr-osmosdr
skip sudo apt-get install qtbase5-dev libqt5svg5-dev libpulse-dev libasound-dev
skip build_submodule gqrx

# TODO: more boost cmake pain
skip sudo apt-get install libqt5websockets5-dev libopus-dev qtmultimedia5-dev libopencv-dev libboost-dev
skip build_submodule cm256cc
skip build_submodule dsdcc
skip build_submodule mbelib
skip build_submodule serialDV
skip build_submodule sdrangel "-DSERIALDV_DIR=$install_prefix"

source env.sh
sudo apt-get install llvm libclang-dev clang
(
    cd ext/rust-soapysdr
    cargo build --features binaries --release
    for binary in soapy-sdr-info soapy-sdr-stream; do
        sudo install -m 755 -D "target/release/$binary" "$install_prefix/bin/$binary"
    done
)

sudo tee /etc/ld.so.conf.d/sdr-stuff.conf <<EOF
$install_prefix/lib
EOF
sudo ldconfig

if [[ ! -e /usr/src/xtrx-0.0.1-2 ]]; then
    sudo ln -sf "$ext_dir"/xtrx_linux_pcie_drv /usr/src/xtrx-"$xtrx_pcie_drv_version"
    sudo dkms install xtrx/"$xtrx_pcie_drv_version"
    sudo modprobe xtrx
fi

sudo tee /etc/udev/rules.d/50-xtrx.rules <<EOF
KERNEL=="xtrx*", SUBSYSTEM=="xtrx", MODE="0666"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger

(
    cd ext/LimeSuite/udev-rules
    sudo sh ./install.sh
)

if [[ -e "$install_prefix/share/Lime/Desktop/install" ]]; then
    "$install_prefix/share/Lime/Desktop/install"
fi

