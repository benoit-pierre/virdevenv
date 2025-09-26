#!/bin/bash

set -eo pipefail

if [[ $# -lt 1 ]] || [[ $# -gt 2 ]]; then
    echo "USAGE: $0 PLATFORM [VERSION]" 1>&2
    exit 1
fi

platform="$1"
version="${2:-2025.05}"

echo "installing x-tools: $platform $version"

wget -nv "https://github.com/koreader/koxtoolchain/releases/download/$version/$platform.tar.gz"
tar xzv --no-same-owner -C /usr/local -f "$platform.tar.gz"
rm "$platform.tar.gz"
cd /usr/local
chmod +w,og=rX -R x-tools/*/
rm -vf x-tools/*/build.log.bz2
hardlink x-tools/

# vim: sw=4
