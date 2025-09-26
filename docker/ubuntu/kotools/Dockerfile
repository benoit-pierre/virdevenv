RUN apt-get update -y
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    jq \
    make \
    python3-pip \
    python3-pkg-resources \
    python3-setuptools \
    wget \
    ;

# Copy over common tools from kobase.
COPY --from=kobase /usr/local /usr/local

# hadolint
ARG HADOLINT_VERSION="2.14.0"
RUN wget -nv -O /usr/local/bin/hadolint "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-linux-x86_64"
RUN chmod 755 /usr/local/bin/hadolint
RUN hadolint --version

# pylint
ARG PYLINT_VERSION="3.3.8"
RUN pip install --no-cache-dir pylint==${PYLINT_VERSION}

# regctl
ARG REGCTL_VERSION="0.9.2"
RUN wget -nv -O /usr/local/bin/regctl "https://github.com/regclient/regclient/releases/download/v${REGCTL_VERSION}/regctl-linux-amd64"
RUN chmod 755 /usr/local/bin/regctl
RUN regctl version

# Cleanup.
RUN rm /usr/local/bin/ccache
RUN rm /usr/local/bin/ninjatracing
RUN pip uninstall -y meson
RUN luarocks remove luacov-coveralls
RUN luarocks remove luacov
RUN luarocks remove datafile
RUN luarocks remove dkjson
RUN luarocks remove lua-path
RUN rm -rf \
    /usr/local/bin/luarocks \
    /usr/local/bin/luarocks-admin \
    /usr/local/etc/luarocks \
    /usr/local/share/lua/5.1/datafile/openers/luarocks.lua \
    /usr/local/share/lua/5.1/luarocks \
    ;
RUN apt-get remove -y --auto-remove \
    python3-pip \
    ;
