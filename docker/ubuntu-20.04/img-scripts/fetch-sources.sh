#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"/..

source /base-functions.sh

git config --global advice.detachedHead false

git_repository() {
	banner "Fetch $BUILD_TARGET (git_repository $*)"

	repo=$1
	checkout=$2
	shift 2
	git clone "$repo" "$SOURCE_DIR"
	(
		cd "$SOURCE_DIR"
		git checkout "$checkout"
	)
}

git_fetch_submodules() {
	(
		cd "$SOURCE_DIR"
		git submodule update --init "$@"
	)
}

for build in "$@"; do
	source "$build"
done
