#!/bin/bash
TOML="${1:-$(pwd)/project.toml}"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
NODE=$(hostname)
UUID=$(cat /proc/sys/kernel/random/uuid)
HASH=$(pip freeze 2>/dev/null | sha256sum | cut -d' ' -f1)

if [ -f "$TOML" ]; then
  BACKUP="${TOML}.backup_${TS}"
  cp "$TOML" "$BACKUP"
  echo "backup: $BACKUP"
  NAME=$(grep "^name" "$TOML" | head -1 | cut -d'=' -f2 | tr -d ' "')
  TYPE=$(grep "^type\|^domain" "$TOML" | head -1 | cut -d'=' -f2 | tr -d ' "')
  ENV=$(grep "^env\|^venv" "$TOML" | head -1 | cut -d'=' -f2 | tr -d ' "')
  echo "migrating existing: $NAME"
else
  NAME=$(basename $(pwd))
  TYPE="unknown"
  ENV=".venv"
  echo "no toml found — creating new for: $NAME"
fi

[ -z "$NAME" ] && NAME=$(basename $(pwd))
[ -z "$TYPE" ] && TYPE="unknown"
[ -z "$ENV"  ] && ENV=".venv"

REQUIRES=$(pip freeze 2>/dev/null \
  | grep -v "^#" \
  | awk -F'==' '{print "\"" $1 "\""}' \
  | paste -sd',' -)

MANAGERS="pip"
[ -f "$(pwd)/pyproject.toml" ] && MANAGERS="$MANAGERS uv"
[ -f "$(pwd)/Cargo.toml" ]     && MANAGERS="$MANAGERS cargo"
[ -f "$(pwd)/package.json" ]   && MANAGERS="$MANAGERS npm"
command -v conda &>/dev/null   && MANAGERS="$MANAGERS conda"

cat > "$TOML" << TOMLEOF
# ── identity ──────────────────────────────────────────────
[project]
name        = "$NAME"
version     = "0.1.0"
description = ""
state       = "active"
author      = "$USER"

# ── type ──────────────────────────────────────────────────
[type]
domain      = "$TYPE"
subtype     = ""
category    = ""

# ── runtime ───────────────────────────────────────────────
[runtime]
env         = "dev"
target      = "local"
venv        = "$ENV"
min_ram     = ""
min_disk    = ""

# ── managers ──────────────────────────────────────────────
[managers]
active      = "$MANAGERS"
pip         = "true"
apt         = ""
npm         = ""
cargo       = ""
conda       = ""

# ── dependencies ──────────────────────────────────────────
[dependencies]
python      = "$(python3 --version 2>/dev/null | cut -d' ' -f2)"
requires    = [$REQUIRES]
dev         = []
peer        = []
apt         = []
npm         = []
cargo       = []

# ── fingerprint ───────────────────────────────────────────
[fingerprint]
hash            = "$HASH"
generated_at    = "$TS"
generated_by    = "$USER"
last_known_good = ""

# ── snap ──────────────────────────────────────────────────
[snap]
name        = ""
tier        = ""
path        = ""
created_at  = ""
created_by  = ""

# ── log domains ───────────────────────────────────────────
[log]
active = ["terminal","registry","dep"]

# ── registry ──────────────────────────────────────────────
[registry]
project_id  = "$UUID"
node        = "$NODE"
locked_by   = ""
lock_time   = ""

# ── container ─────────────────────────────────────────────
[container]
type        = ""
image       = ""
status      = "idle"
node        = "$NODE"
vhd         = ""
TOMLEOF

echo "done: $TOML"
echo "uuid: $UUID"
echo "hash: ${HASH:0:16}..."
echo "packages: $(pip freeze 2>/dev/null | wc -l)"

REG_CONF=~/project/project_path/data/registry.conf
if ! grep -q "^$NAME:" "$REG_CONF" 2>/dev/null; then
  echo "$NAME:$(pwd):$ENV:dev:$TYPE" >> "$REG_CONF"
  echo "registered: $NAME"
fi
bash ~/project/project_path/cmd/config/onboard_deps.sh "$(dirname $TOML)"
