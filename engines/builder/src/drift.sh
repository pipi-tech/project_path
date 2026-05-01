#!/bin/bash
[ -z "$PROJECT_NAME" ] && echo "no project name" && exit 1
REG_CONF=~/project/project_path/data/registry.conf
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
  bash ~/project/project_path/data/log/registry/src/on_drift.sh \
    "$PROJECT_NAME" "$STORED_HASH" "$CURRENT_HASH" "$TS"
else
  echo "  ✓ no drift"
fi
