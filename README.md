XTRX-o-matic
======

Because the XTRX project maintainers don't exist, apparently, and I'm SO DAMN TIRED of searching the internet for patches that have been out there for months or years, and fixing newly-introduced bugs.

I'm collecting here some patched versions of ALL THE THINGS so that I can actually use my XTRX radios.  I'm also including some build scripts that WORK FOR ME AND PROBABLY ME ONLY.  They bake in a lot of assumptions about where I want my shit to be put, and you might not want the same.  This whole thing was written in a state of annoyance, and I don't much care right now if it's useful for anyone else.  Someday I might, but not today.

My target environments:

- Ubuntu 18.04 amd64
- Ubuntu [18.04??] arm64
- macOS

My target software integrations:

- ANYTHING with a real-time waterfall display for HW validation.  gqrx? sdrangel? sdrangelove? gnu radio companion with fosphor (although this one is its own giant can of shitty worms to get running)?
- whatever tools i need to flash new code/bitstream/etc to the XTRX
- rust language (probably via SoapySDR) so I can finally quit shaving yaks and actually use these radios for my real projects

My target XTRX hardware:

- XTRX community edition
- XTRX USB3 adapter
- XTRX PCIe x2 FE adapter
- XTRX octopack

What currently works?

- builds and runs test.grc flowgraph on my ubuntu desktop, after 3 hours of infuriating NVIDIA driver hell.
- gqrx works with soapy drivers (doesn't seem to work with soapy=0 in device string, haven't investigated)
- rx_sdr stuff works
- rust-soapysdr works, with soapy-sdr-{info,stream} as a couple example/test binaries

Notable things that don't currently work:

- xtrx soapy driver enumeration: current implementation COMPLETELY IGNORES the provided "match args".  You get the first device in the list.  Don't care if you want it or not.  Also, it doesn't know the difference between an XTRX and a LimeSDR - XTRX driver will try to enumerate a LimeSDR but will fail with incompatible gateware.
- soapy-sdr-stream demo app (from rust-soapysdr) file i/o is much too slow for use on xavier at sample rates over ~10 MHz.  This is more just a thing to be aware of, we don't actually need this to be fast but we also don't want to incorrectly assume the streaming itself is broken because this demo drops frames.
