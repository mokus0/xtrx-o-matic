#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

rm -Rf tmp
mkdir tmp
cp -R ../../builds ../../builds.in-dev tmp/

source build-scripts/base-functions.sh

build-scripts/fetch-sources.sh ../../builds/*.build ../../builds.in-dev/*.build
build-scripts/build-sources.sh ../../builds/*.build ../../builds.in-dev/*.build
