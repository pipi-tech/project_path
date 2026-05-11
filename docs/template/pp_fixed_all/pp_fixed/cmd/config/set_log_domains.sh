#!/bin/bash
# WHAT:  Sets active log domains in project.toml based on project type
# WIRES: Called by cmd/builder/build.sh → reads cmd/config/type_registry.conf → writes to project.toml
# WHY:   Keeps log domain config tied to project type — different project types emit different events

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOML="$1"
TYPE_REG="$SELF_DIR/type_registry.conf"

[ -z "$TOML" ] && echo "usage: set_log_domains.sh <project.toml>" && exit 1
[ ! -f "$TOML" ] && echo "toml not found: $TOML" && exit 1

TYPE=$(grep "^subtype\|^domain" "$TOML" | head -1 | cut -d'=' -f2 | tr -d ' "')
DOMAINS=$(grep "^$TYPE:" "$TYPE_REG" 2>/dev/null | cut -d: -f2)

if [ -z "$DOMAINS" ]; then
  echo "  ⚠ type '$TYPE' not in type_registry — using default"
  DOMAINS="terminal,registry"
  echo "  tip: add '$TYPE:terminal,registry' to type_registry.conf to customize"
fi

FORMATTED=$(echo "$DOMAINS" | tr ',' '\n' | sed 's/.*/\"&\"/' | paste -sd',' -)
sed -i "s|^active.*=.*|active = [$FORMATTED]|" "$TOML"
echo "  log.active set to: [$FORMATTED]"
