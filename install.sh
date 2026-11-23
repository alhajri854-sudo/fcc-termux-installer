#!/usr/bin/env bash
set -euo pipefail

termux-wake-lock

export UV_PYTHON_PREFERENCE=only-system
export GRPC_PYTHON_BUILD_EXT_COMPILER_JOBS=1
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
export GRPC_PYTHON_BUILD_SYSTEM_CARES=1
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

echo "=== تحديث Termux وتثبيت المتطلبات ==="
pkg update -y && pkg upgrade -y
pkg install -y python python-grpcio clang make cmake ninja pkg-config openssl c-ares zlib libffi rust uv git || \
pkg install -y python clang make cmake ninja pkg-config openssl c-ares zlib libffi rust uv git

echo "=== بدء تثبيت free-claude-code==6.19.11 ==="
set +e
uv tool install --force \
    --refresh-package free-claude-code \
    --python "$(command -v python)" \
    --with-executables-from free-claude-code \
    free-claude-code==6.19.11 \
    -vv 2>&1 | tee "$HOME/fcc-install-native.log"
INSTALL_STATUS="${PIPESTATUS[0]}"
set -e

echo "=== كود الخروج: $INSTALL_STATUS ==="
exit "$INSTALL_STATUS"
