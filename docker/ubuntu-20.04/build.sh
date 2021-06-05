#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

rm -Rf tmp
mkdir tmp
cp -R ../../builds ../../builds.in-dev tmp/

host-scripts/collect-deps.sh tmp/builds
host-scripts/collect-deps.sh tmp/builds.in-dev

docker build -t 'xtrx-o-matic:ubuntu-20.04' .