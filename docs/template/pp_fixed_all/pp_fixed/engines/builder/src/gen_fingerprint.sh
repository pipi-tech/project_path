#!/bin/bash
# WHAT:  Generates sha256 fingerprint of current pip freeze state and writes to toml
# WIRES: Called by engines/builder/src/build.sh → writes hash/ts/user to project.toml
# WHY:   State identity — fingerprint is the content-addressable ID of this environment
[ -z "$PROJECT_NAME" ] && echo "no project name" && exit 1
TOML="$1"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
HASH=$(pip freeze 2>/dev/null | sha256sum | cut -d' ' -f1)

echo "hash=$HASH"
echo "generated_at=$TS"
echo "generated_by=$USER"

export FINGERPRINT_HASH=$HASH
export FINGERPRINT_TS=$TS

[ -z "$TOML" ] && exit 0
[ ! -f "$TOML" ] && exit 0

sed -i "s|^hash.*=.*|hash            = \"$HASH\"|" "$TOML"
sed -i "s|^generated_at.*=.*|generated_at    = \"$TS\"|" "$TOML"
sed -i "s|^generated_by.*=.*|generated_by    = \"$USER\"|" "$TOML"
