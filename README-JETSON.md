Some setup notes specific to Jetson platforms
====

General
----

Some L4T targets (mainly older ones, I think) will have a default boot configuration that doesn't provide as many DMA resources as the XTRX driver will want.  It is recommended to add the following kernel command-line arguments:

	vmalloc=512M cma=64M coherent_pool=32M pci=noaer

This is done in a different way depending on the L4T version.  In older ones, you can edit the APPEND line in /boot/extlinux/extlinux.conf.  In newer ones you have to modify and re-flash the cboot kernel config to add the kernel arguments.  The one that ships with the Jetson AGX Xavier doesn't appear to need this.
