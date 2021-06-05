XTRX-o-matic
=============

This project started life as a script for building libxtrx and soapysdr 0.8.0 from source, since the apt repos on my systems have an older soapysdr and no libxtrx.  It has evolved beyond that, now, to a generic setup script for a bunch of radio software I use in my home lab.  This is designed to set things up in a simple, opinionated way and if you don't like it, you're welcome to not use it.  It's also very untested outside my own specific environment - you should probably just start from the assumption it won't work in yours, and be pleasantly surprised if it does.

My target operating systems (right now, only ubuntu/pop 20.04 build is implemented; macos probably coming eventually):

* Ubuntu/Pop!\_OS 20.04 amd64
* Ubuntu [18.04??] arm64
* macOS amd64
* macoS arm64

My primary target hardware:
* Desktop/laptop computer running linux or macos
* NVIDIA Jetson TX2 / AGX Xavier dev kit
* Various RTL-SDR dongles
* LimeSDR
* XTRX
* USRP X310

My primary target software (this installs some other stuff on a best-effort basis but it's really not tested much if at all, even in my own environment):
* SoapySDR 0.8
* XTRX soapy driver
* UHD 4
* GNU Radio 3.9
* GQRX
* SDRAngel

Usage
---

* Poke around for the scripts you want, then run them.  The ones most likely to work as of this commit are the ones for Ubuntu 20.04.  For example, to build and install natively on an Ubuntu 20.04 system (i.e., not in a container but on the actual host doing the building), run:
    * native/ubuntu-20.04/install-deps.sh && native/ubuntu-20.04/build.sh
* If something doesn't work, let me know... I might not have time to do anything about it but if you create a github "issue" at least other people will know too.  If something does work, it'd be nice to let me know about that too - I don't test this very extensively since it was only ever meant to work for me, but if it also works for others that'd be nifty.
* After installation, to run stuff you'll need to set certain paths in your environment.  "source env.sh" should get you there, or close at least.

Organization
---

These scripts are build around a bunch of individual files for each group of software it builds.  In the main 'builds' subdirectory there are a bunch of files named `*.build`.  These are just bash scripts, but they are meant to be interpreted somewhat declaratively.  They are sourced multiple times in different contexts with different implementations of the functions they call, depending on the purpose of the current invocation.  The implementations are ad-hoc, repetitive, and messy.  Enter at your own risk.

Quirks
---

* On Pop!\_OS 20.04, not sure why but some stuff acts differently from the ubuntu docker image I did inital testing in.  In particular, cmake whines about boost-chrono-dev declaring /include as an include dir while that path doesn't exist.  I haven't dug into why, because I don't care that much right now.  My quick ugly hack was to create a symlink /include -> /usr/include. YMMV.
* On NVIDIA Tegra systems, some L4T targets (mainly older ones, I think) will have a default boot configuration that doesn't provide as many DMA resources as the XTRX driver will want.  It is recommended to add the following kernel command-line arguments:

    vmalloc=512M cma=64M coherent_pool=32M pci=noaer

This is done in a different way depending on the L4T version.  In older ones, you can edit the APPEND line in /boot/extlinux/extlinux.conf.  In newer ones you have to modify and re-flash the cboot kernel config to add the kernel arguments.  The one that ships with the Jetson AGX Xavier doesn't appear to need this.

TODO: more documentation, less clutter, etc.
