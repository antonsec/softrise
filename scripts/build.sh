#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Resolve local installations without storing machine paths in tracked files.
if [[ -z "${JAVA_HOME:-}" ]] && command -v brew >/dev/null; then
    java_prefix="$(brew --prefix openjdk@17 2>/dev/null || true)"
    if [[ -x "$java_prefix/bin/java" ]]; then
        export JAVA_HOME="$java_prefix/libexec/openjdk.jdk/Contents/Home"
    fi
fi
if [[ -n "${JAVA_HOME:-}" ]]; then export PATH="$JAVA_HOME/bin:$PATH"; fi
sdk="${CIQ_SDK_HOME:-}"
if [[ -z "$sdk" ]]; then
    sdk_config="$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"
    if [[ -f "$sdk_config" ]]; then sdk="$(cat "$sdk_config")"; fi
fi
if [[ ! -f "$sdk/bin/monkeybrains.jar" ]]; then
    echo 'No active Connect IQ SDK. Complete SDK Manager setup and select an active SDK.' >&2
    echo 'Alternatively set CIQ_SDK_HOME to an installed SDK directory.' >&2
    exit 1
fi
key="${CIQ_DEVELOPER_KEY:-.local/developer_key.der}"
if [[ ! -f "$key" ]]; then
    echo 'Missing signing key. Run: bash scripts/create-key.sh' >&2
    exit 1
fi
mkdir -p bin
output=bin/SoftRise.prg
set -- "${1:-}"
build_mode="$1"
set --
if [[ "$build_mode" == "--test" ]]; then
    output=bin/SoftRise-tests.prg
    set -- -t
elif [[ "$build_mode" == "--device" ]]; then
    set -- -r
elif [[ -n "$build_mode" ]]; then
    echo 'Usage: bash scripts/build.sh [--device|--test]' >&2
    exit 1
fi
java -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar "$sdk/bin/monkeybrains.jar" \
    -f monkey.jungle -d fr265 -o "$output" -y "$key" -w "$@"
