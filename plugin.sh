#!/bin/sh
here="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
sys="$(uname -s)"
case "$sys" in
MINGW* | MSYS* | CYGWIN*) rel="x86_64-pc-windows-msvc/gray-guard.exe" ;;
Darwin*)
    case "$(uname -m)" in
    arm64) rel="aarch64-apple-darwin/gray-guard" ;;
    *) rel="x86_64-apple-darwin/gray-guard" ;;
    esac ;;
*)
    case "$(uname -m)" in
    aarch64 | arm64) rel="aarch64-unknown-linux-musl/gray-guard" ;;
    *) rel="x86_64-unknown-linux-musl/gray-guard" ;;
    esac ;;
esac
if [ -x "$here/$rel" ]; then exec "$here/$rel" "$@"; fi
for cand in "$here/target/release/gray-guard.exe" "$here/target/release/gray-guard" "$here/target/debug/gray-guard.exe" "$here/target/debug/gray-guard"; do
    if [ -x "$cand" ]; then exec "$cand" "$@"; fi
done
echo "gray-guard binary not found in $here" >&2
exit 1
