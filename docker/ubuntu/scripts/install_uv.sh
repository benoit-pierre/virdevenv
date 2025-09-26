#!/bin/bash

set -eo pipefail

version="${1:-0.8.22}"

wget -nv -O - "https://github.com/astral-sh/uv/releases/download/${version}/uv-x86_64-unknown-linux-gnu.tar.gz" | tar -C /usr/local/bin --strip-components=1 -xz
chmod 755 /usr/local/bin/{uv,uvx}
uv --version
