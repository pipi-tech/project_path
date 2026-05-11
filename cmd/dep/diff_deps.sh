#!/bin/bash
# WHAT:  Diffs before/after pip freeze snapshots and updates project.toml requires
# WIRES: Called by functions/dep_wrappers.sh → reads data/log/dep/input/before+after → writes data/log/dep/input/diff/
# WHY:   Produces an auditable record of exactly what each install added or removed

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../.." && pwd)"

PROJECT="$1"
TS="$2"
BEFORE="$PTH_ROOT/data/log/dep/input/before/$TS.txt"
AFTER="$PTH_ROOT/data/log/dep/input/after/$TS.txt"
DIR="$PTH_ROOT/data/log/dep/input/diff"
TOML="$(pwd)/project.toml"
mkdir -p "$DIR"

[ ! -f "$BEFORE" ] && echo "no before snapshot" && exit 1
[ ! -f "$AFTER" ]  && echo "no after snapshot"  && exit 1

BEFORE_PKGS=$(awk '/^--- pip freeze ---/{found=1; next} /^---/{found=0} found{print}' "$BEFORE")
AFTER_PKGS=$(awk '/^--- pip freeze ---/{found=1; next} /^---/{found=0} found{print}' "$AFTER")

ADDED=$(comm -13 \
  <(echo "$BEFORE_PKGS" | sort) \
  <(echo "$AFTER_PKGS"  | sort))

REMOVED=$(comm -23 \
  <(echo "$BEFORE_PKGS" | sort) \
  <(echo "$AFTER_PKGS"  | sort))

echo "project=$PROJECT" > "$DIR/$TS.txt"
echo "ts=$TS"          >> "$DIR/$TS.txt"
echo "user=$USER"      >> "$DIR/$TS.txt"
echo "--- added ---"   >> "$DIR/$TS.txt"
echo "$ADDED"          >> "$DIR/$TS.txt"
echo "--- removed ---" >> "$DIR/$TS.txt"
echo "$REMOVED"        >> "$DIR/$TS.txt"
echo "--- before count ---" >> "$DIR/$TS.txt"
echo "$BEFORE_PKGS" | grep -c "==" >> "$DIR/$TS.txt"
echo "--- after count ---" >> "$DIR/$TS.txt"
echo "$AFTER_PKGS" | grep -c "==" >> "$DIR/$TS.txt"

if [ -f "$TOML" ] && grep -q "^\[dependencies\]" "$TOML"; then
  REQUIRES=$(echo "$AFTER_PKGS" \
    | grep "==" \
    | awk -F'==' '{print "\"" $1 "\""}' \
    | paste -sd',' -)
  sed -i "s|^requires.*=.*|requires    = [$REQUIRES]|" "$TOML"
  echo "toml updated: requires"
fi
