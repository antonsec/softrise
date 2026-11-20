#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
umask 077
mkdir -p .local
if [[ -e .local/developer_key.der ]]; then
    echo 'Signing key already exists; leaving it unchanged.'
    exit 0
fi
openssl genrsa -out .local/developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER \
    -in .local/developer_key.pem -out .local/developer_key.der -nocrypt
echo 'Created private signing files in ignored .local/. Keep them private and backed up.'
