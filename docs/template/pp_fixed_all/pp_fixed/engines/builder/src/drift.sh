#!/bin/bash
# WHAT:  Compares stored fingerprint hash vs current pip freeze hash to detect environment drift
# WIRES: Called by cmd/builder/build.sh and functions/builder.sh (drift) → reads data/registry.conf → calls data/log/registry/src/on_drift.sh
# WHY:   Drift detection engine — catches silent environment changes between builds

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"

[ -z "$PROJECT_NAME" ] && echo "no project name" && exit 1
REG_CONF="$PTH_ROOT/data/registry.conf"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
STORED_HASH=$(grep -i "^$PROJECT_NAME:" "$REG_CONF" 2>/dev/null | cut -d: -f6)
CURRENT_HASH=$(pip freeze 2>/dev/null | sha256sum | cut -d' ' -f1)

if [ -z "$STORED_HASH" ]; then
  echo "no previous fingerprint — skipping drift check"
  exit 0
fi

if [ "$STORED_HASH" != "$CURRENT_HASH" ]; then
  echo "  ⚠ drift detected"
  echo "  stored:  $STORED_HASH"
  echo "  current: $CURRENT_HASH"
  bash "$PTH_ROOT/data/log/registry/src/on_drift.sh" \
    "$PROJECT_NAME" "$STORED_HASH" "$CURRENT_HASH" "$TS"
else
  echo "  ✓ no drift"
fi
