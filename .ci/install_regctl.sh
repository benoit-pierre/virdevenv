#!/bin/sh

VERSION='0.9.2'

set -xe

os="$(uname -s -m | tr ' ' /)"
case "${os}" in
    Linux/aarch64) arch=arm64 ;;
    Linux/x86_64) arch=amd64 ;;
    *)
        echo "unsupport OS: ${os}" 1>&2
        exit 1
        ;;
esac

mkdir -p ~/.local/bin
cd ~/.local/bin
curl --location --output regctl "https://github.com/regclient/regclient/releases/download/v${VERSION}/regctl-linux-${arch}"
chmod +x regctl
regctl version
