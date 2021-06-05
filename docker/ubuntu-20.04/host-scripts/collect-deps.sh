#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"/..

source host-scripts/base-functions.sh

builds_dir=$1

build_deps=()
runtime_deps=()

apt_build_dependencies() {
	build_deps+=( "$@" )
}

apt_dependencies() {
	runtime_deps+=( "$@" )
}

git_repository() {
	apt_build_dependencies git
}

cmake_build() {
	apt_build_dependencies cmake
}

cmake_build_subdir() {
	apt_build_dependencies cmake
}

for build in "$builds_dir"/*.build; do
	source "$build"
done

format_deps() {
	for dep in "$@"; do
		echo "$dep"
	done | sort | uniq
}

mkdir -p img-data
format_deps "${build_deps[@]}" > "$builds_dir"/build.deps
format_deps "${runtime_deps[@]}" > "$builds_dir"/runtime.deps
