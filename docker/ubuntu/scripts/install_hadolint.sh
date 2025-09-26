#!/bin/bash

set -eo pipefail

version="${1:-2.14.0}"

wget -nv -O /usr/local/bin/hadolint "https://github.com/hadolint/hadolint/releases/download/v${version}/hadolint-linux-x86_64"
chmod 755 /usr/local/bin/hadolint
hadolint --version
