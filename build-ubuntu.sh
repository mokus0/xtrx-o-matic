#!/bin/bash

set -euo pipefail
shellcheck "$0"

script_dir=$(cd "$(dirname "$0")" && pwd)
ext_dir=$script_dir/ext

install_prefix=/opt/sdr
xtrx_pcie_drv_version=0.0.1-2

# YUCK. python can't handle "from gnuradio import blah" unless "blah" 
# is literally in the first gnuradio directory it finds.  So these files can't
# go into /opt with everything else.
gr_python_dir=/usr/lib/python2.7/dist-packages

sudo apt-get install gpsd gpsd-clients pps-tools

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

# sudo apt-get install nvidia-opencl-dev opencl-headers libglfw3-dev
# build_submodule gr-fosphor "-DGR_PYTHON_DIR=$gr_python_dir" -DOPENCL_LIBRARY=/usr/lib/x86_64-linux-gnu/libOpenCL.so

build_submodule libusb3380
build_submodule xtrx_linux_pcie_drv
build_submodule liblms7002m
build_submodule libxtrxll
build_submodule libxtrxdsp
build_submodule libxtrx

build_submodule LimeSuite

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

sudo apt-get install gnuradio-dev
build_submodule gr-osmosdr "-DGR_PYTHON_DIR=$gr_python_dir"

sudo apt-get install qtbase5-dev libqt5svg5-dev libpulse-dev
build_submodule gqrx

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

