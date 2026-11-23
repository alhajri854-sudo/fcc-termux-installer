#!/usr/bin/env bash
set -euo pipefail

termux-wake-lock

export UV_PYTHON_PREFERENCE=only-system
export GRPC_PYTHON_BUILD_EXT_COMPILER_JOBS=1
export PIP_NO_BUILD_ISOLATION=1

echo "=== تحديث Termux وتثبيت المتطلبات ==="
pkg update -y && pkg upgrade -y
pkg install -y python clang make cmake ninja pkg-config openssl libffi rust uv git

echo "=== جلب مصدر grpcio 1.85.1 إلى كاش uv ==="
uv pip install --dry-run --no-build-isolation --refresh-package grpcio==1.85.1 grpcio==1.85.1 >/dev/null 2>&1 || true

CACHE="$(uv cache dir)"
H="$(find "$CACHE" -type f -path '*/grpcio/1.85.1*/third_party/cares/ares_config.h' -print -quit 2>/dev/null || true)"

if [ -z "$H" ]; then
    echo "خطأ: لم يتم العثور على ares_config.h في كاش uv. تأكد من الاتصال بالإنترنت."
    exit 1
fi

printf '#include "ares_config.h"\n' | clang -E -x c -I"${H%/*}" - >/dev/null
echo "تم التحقق من الترويسة بنجاح: $H"

echo "=== بدء تثبيت free-claude-code==6.19.11 ==="
set +e
uv tool install --force \
    --refresh-package free-claude-code \
    --python "$(command -v python)" \
    free-claude-code==6.19.11 \
    -vv 2>&1 | tee "$HOME/fcc-install-native.log"
INSTALL_STATUS="${PIPESTATUS[0]}"
set -e

echo "=== كود الخروج: $INSTALL_STATUS ==="
exit "$INSTALL_STATUS"
