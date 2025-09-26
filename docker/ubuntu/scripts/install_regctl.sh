#!/bin/bash

set -eo pipefail

version="${1:-0.9.2}"

wget -nv -O /usr/local/bin/regctl "https://github.com/regclient/regclient/releases/download/v${version}/regctl-linux-amd64"
chmod 755 /usr/local/bin/regctl
regctl version
