#!/bin/bash
# WHAT:  Registers or updates a project in registry.conf and logs the event
# WIRES: Called by engines/builder/src/build.sh → writes to data/registry.conf and data/registry.txt → calls data/log/registry/src/on_register.sh or on_update.sh
# WHY:   Identity registration — makes a project findable by name across all system commands

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"

[ -z "$PROJECT_NAME" ] && echo "no project name" && exit 1

REG_LOG="$PTH_ROOT/data/registry.txt"
REG_CONF="$PTH_ROOT/data/registry.conf"
TOML="$1"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
NODE=$(hostname)
UUID=$(cat /proc/sys/kernel/random/uuid)
PROJECT_ROOT="${PROJECT_SAVE_PATH:-$HOME/project}/$PROJECT_NAME"

echo "$TS :: $USER :: $PROJECT_NAME :: $PROJECT_TYPE :: $PROJECT_ENV :: $FINGERPRINT_HASH" >> "$REG_LOG"

if ! grep -q "^$PROJECT_NAME:" "$REG_CONF" 2>/dev/null; then
  echo "$PROJECT_NAME:$PROJECT_ROOT:$PROJECT_VENV:$PROJECT_ENV:$PROJECT_TYPE" >> "$REG_CONF"
  bash "$PTH_ROOT/data/log/registry/src/on_register.sh" "$PROJECT_NAME" "$TS"
else
  sed -i "s|^$PROJECT_NAME:.*|$PROJECT_NAME:$PROJECT_ROOT:$PROJECT_VENV:$PROJECT_ENV:$PROJECT_TYPE|" "$REG_CONF"
  bash "$PTH_ROOT/data/log/registry/src/on_update.sh" "$PROJECT_NAME" "$TS"
fi

[ -f "$TOML" ] && sed -i "s|^project_id.*=.*|project_id  = \"$UUID\"|" "$TOML"
[ -f "$TOML" ] && sed -i "s|^node.*=.*|node        = \"$NODE\"|" "$TOML"

echo "registered: $PROJECT_NAME :: $UUID :: $NODE"
