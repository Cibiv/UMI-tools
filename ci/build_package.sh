#!/bin/bash

# Stop on error
set -o pipefail
set -e

# Locate "test" directory, include depdenencies.sh
export CIDIR="$( cd "$(dirname "$0")" ; pwd -P )"
source "$CIDIR/dependencies.sh"

# Create temporary working directory, make it the cwd
WORKDIR="$(mktemp -d)"
if ! test -d "$WORKDIR"; then
	WORKDIR=""
	echo "Failed to create temporary working directory ($WORKDIR is not a directory):" >&2
	exit 1
fi
echo "=== Created working directory $WORKDIR"

# Cleanup on exit
function on_exit() {
	if test "$WORKDIR" != "" && test "$KEEP_WORKDIR" == ""; then
		echo "=== Removing working directory $WORKDIR"
		rm -rf "$WORKDIR"
	fi
}
trap on_exit EXIT

# Setup conda test environment
. $HOME/ci/conda/etc/profile.d/conda.sh
BUILDENV="$WORKDIR/buildenv"
echo "=== Creating and activating test environment in $BUILDENV"
conda create --no-default-packages -p "$BUILDENV" \
	python=$TRAVIS_PYTHON_VERSION \
	pip \
	conda-build \
	anaconda-client 
conda activate "$BUILDENV"

# Build package
# NOTE: This will re-download the sources from github, and always
# build the version indicated in conda-recipe/meta.yaml, NOT
# the currently checked-out version. Thats OK, though, since we
# only run this on travis-ci and check that TRAVIS_TAG equals
# the version in conda-recipe/meta.yaml.
mkdir -p conda-bld
if [[ "$TRAVIS_TAG" != "" ]]; then
	export BUILD_VERSION="$TRAVIS_TAG"
else
	export BUILD_VERSION="commit-$(git rev-parse --short HEAD)"
fi
conda build conda-recipe \
	--no-test \
	--no-anaconda-upload \
	--no-build-id \
	--output-folder="$(pwd -P)/conda-bld"
