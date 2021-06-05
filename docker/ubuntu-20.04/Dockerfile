FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade && rm -rf /var/lib/apt/lists/*

COPY img-scripts/install-deps.sh /
COPY tmp/builds/*.deps /builds/
RUN /bin/bash -c '/install-deps.sh /builds'

RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen \
	&& locale-gen \
	&& update-locale LANG=en_US.UTF-8

RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-local \
	&& useradd -m -G sudo peon
RUN mkdir -p /build && chown -R peon /build

COPY host-scripts/base-functions.sh /
COPY img-scripts/ /
COPY tmp/builds/*.build /builds/

RUN /bin/bash -c '/fetch-sources.sh builds/*.build'
RUN sudo -u peon /bin/bash -c '/build-sources.sh builds/*.build'

COPY tmp/builds.in-dev/*.deps /builds.in-dev/
RUN /bin/bash -c '/install-deps.sh /builds.in-dev'

COPY tmp/builds.in-dev/*.build /builds.in-dev/
RUN /bin/bash -c '/fetch-sources.sh builds.in-dev/*.build'
RUN sudo -u peon /bin/bash -c '/build-sources.sh builds/00-global-setup.build builds.in-dev/*.build'

RUN /bin/bash /clean-deps.sh /builds /builds.in-dev
