#!/bin/bash

set -e

VERSION="1.4.0"
SHA256="25378635ab396195d2bc8d58ee2988383fccf0699d2c5222800c8a37524179c7"
URL="https://libreclinica.org/downloads/LibreClinica-web-${VERSION}.war"
DEST="$(dirname "$0")/../webapps/libreclinica.war"

wget -O "$DEST" "$URL"
echo "${SHA256}  ${DEST}" | sha256sum -c