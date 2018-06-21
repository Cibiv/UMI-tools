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
DEPLOYENV="$WORKDIR/buildenv"
echo "=== Creating and activating test environment in $DEPLOYENV"
conda create --no-default-packages -p "$DEPLOYENV" \
	 anaconda-client
conda activate "$DEPLOYENV"

# Deploy
anaconda -t "$ANACONDA_TOKEN" upload \
	-u cibiv -l main \
	--no-progress \
	conda-bld/**/umi_tools*.tar.bz2
