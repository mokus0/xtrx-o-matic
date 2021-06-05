Docker-based build

This is a fairly ugly system for automatically building and installing a bunch of related stuff.  I'd much rather set up a PPA but the documentation for debian packaging is horrifically unfriendly.

This set of scripts builds a bunch of dependencies and packages them up in an archive meant to be extracted into /opt on an Ubuntu 20.04 (or Pop!\_OS 20.04) system.  It's at least a bit abstracted into packages with some partial dependency listings, so if I later take the time to learn how to build debian source packages it's a decent start toward that.  For now, though, I just want to get on with USING these things.

TODO: take these same '.build' files and set up a non-docker-based build to run on systems where docker might be a bit more annoying to set up (for example, ARM-based SBC platforms such as Jetson modules)
