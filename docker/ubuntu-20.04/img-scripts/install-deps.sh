#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

builds_dir=$1

apt-get update

apt-get install -y $(cat "$builds_dir"/*.deps)

rm -rf /var/lib/apt/lists/*
