#!/bin/bash
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
