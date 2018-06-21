# Operating System

# Operating system
MACHINE="$(uname -m)"
OS="$(uname -s)"
case "$OS" in
	Darwin)
		CONDAOS="MacOSX"
		PKGSPECOS="osx"
	;;
	Linux)
		CONDAOS="Linux"
		PKGSPECOS="linux"
	;;
	*)
		CONDAOS="$OS"
		PKGSPECOS="$OS"
	;;
esac

# Version of conda to use
CONDA_VERSION=latest
CONDA_ARCHIVE="Miniconda2-$CONDA_VERSION-$CONDAOS-$MACHINE.sh"
CONDA_URL="https://repo.continuum.io/miniconda/$CONDA_ARCHIVE"

function get_archive() {
	local v_archive="${1}_ARCHIVE"
	local v_digest="${1}_DIGEST"
	local v_url="${1}_URL"
	echo "Downloading ${!v_archive} from ${!v_url}"
	curl --silent --show-error --fail --location -o "${!v_archive}" -L "${!v_url}"
}
