#!/usr/bin/env bash
# Build script used by online-judge-verify-helper (see .verify-helper/config.toml).
# Usage: build.sh <source> <output> [crystal build options...]
set -euo pipefail

filename="$1"; shift
output="$1"; shift

if [ "$filename" -nt "$output" ]; then
  echo "Building Crystal project ${filename} with $(crystal --version | head -n 1)..."
  crystal build "$filename" -o "$output" --error-trace "$@"
fi

echo "Build completed."
