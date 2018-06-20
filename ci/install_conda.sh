#!/bin/bash

# ******************************************************************************
# *** Conda Installer for the CI Systems ***************************************
# ******************************************************************************

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
pushd "$WORKDIR" >/dev/null
echo "=== Created working directory $WORKDIR"

# Directory to install conda to
mkdir -p "$HOME/ci"
CONDADIR="$HOME/ci/conda"

if test -d "$CONDADIR"; then
	echo "=== Removing old conda installation in $CONDADIR"
	rm -r "$CONDADIR"
fi
get_archive CONDA
$BASH "$CONDA_ARCHIVE" -b -p "$CONDADIR"
. $HOME/ci/conda/etc/profile.d/conda.sh

# Configure
conda config --set always_yes true
conda config --set anaconda_upload no
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda
