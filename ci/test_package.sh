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
TESTENV="$WORKDIR/buildenv"
echo "=== Creating and activating test environment in $TESTENV"
conda create --no-default-packages -p "$TESTENV" \
	python=$TRAVIS_PYTHON_VERSION
conda activate "$TESTENV"

# Install package
conda install -c "file:///$CIDIR/../conda-bld" umi_tools_tuc

# Install test dependencies
conda install nose pep8 pyyaml

# Run tests
./test_umi_tools.sh
