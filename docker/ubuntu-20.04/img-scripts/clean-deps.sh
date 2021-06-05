#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

build_deps=( )
declare -A runtime_deps
for builds_dir in "$@"; do
	for dep in $(cat "$builds_dir"/build.deps); do
		build_deps+=( $dep )
	done

	for dep in $(cat "$builds_dir"/runtime.deps); do
		runtime_deps[$dep]=1
	done
done

build_only_deps=(  )
for dep in "${build_deps[@]}"; do
	if [[ ! "{runtime_deps[$dep]}" ]]; then
		build_only_deps+=($dep)
	fi
done

apt-get remove -y "${build_only_deps[@]}"
apt-get autoremove -y

rm -rf /var/lib/apt/lists/*
