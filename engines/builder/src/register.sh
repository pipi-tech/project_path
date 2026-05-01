#!/bin/bash
[ -z "$PROJECT_NAME" ] && echo "no project name" && exit 1

REG_LOG=~/project/project_path/data/registry.txt
REG_CONF=~/project/project_path/data/registry.conf
TOML="$1"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
NODE=$(hostname)
UUID=$(cat /proc/sys/kernel/random/uuid)

echo "$TS :: $USER :: $PROJECT_NAME :: $PROJECT_TYPE :: $PROJECT_ENV :: $FINGERPRINT_HASH" >> "$REG_LOG"

if ! grep -q "^$PROJECT_NAME:" "$REG_CONF" 2>/dev/null; then
  echo "$PROJECT_NAME:~/project/$PROJECT_NAME:$PROJECT_VENV:$PROJECT_ENV:$PROJECT_TYPE" >> "$REG_CONF"
  bash ~/project/project_path/data/log/registry/src/on_register.sh "$PROJECT_NAME" "$TS"
else
  sed -i "s|^$PROJECT_NAME:.*|$PROJECT_NAME:~/project/$PROJECT_NAME:$PROJECT_VENV:$PROJECT_ENV:$PROJECT_TYPE|" "$REG_CONF"
  bash ~/project/project_path/data/log/registry/src/on_update.sh "$PROJECT_NAME" "$TS"
fi

[ -f "$TOML" ] && sed -i "s|^project_id.*=.*|project_id  = \"$UUID\"|" "$TOML"
[ -f "$TOML" ] && sed -i "s|^node.*=.*|node        = \"$NODE\"|" "$TOML"

echo "registered: $PROJECT_NAME :: $UUID :: $NODE"
