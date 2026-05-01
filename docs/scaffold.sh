#!/bin/bash
PROJECT="$1"
PROJECT_ROOT="$2"
[ -z "$PROJECT" ]      && echo "no project name" && exit 1
[ -z "$PROJECT_ROOT" ] && echo "no project root" && exit 1
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PP_ROOT="$(cd "$SELF_DIR/.." && pwd)"
TEMPLATE="$PP_ROOT/docs/template"
LOG_SRC="$PP_ROOT/data/log/doc/src"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
DEST="$PROJECT_ROOT/docs"
echo "--- stamping docs: $DEST"
mkdir -p "$DEST/arch"
mkdir -p "$DEST/runbooks"
mkdir -p "$DEST/ref"
mkdir -p "$DEST/log"
for f in arch/DECISIONS.md runbooks/HOW_TO.md; do
  src="$TEMPLATE/$f"
  dst="$DEST/$f"
  if [ ! -f "$dst" ] && [ -f "$src" ]; then
    cp "$src" "$dst"
    echo "  copied: $f"
  else
    echo "  exists (skip): $f"
  fi
done
touch "$DEST/ref/.gitkeep"
touch "$DEST/log/.gitkeep"
sed -i "s|{{PROJECT}}|$PROJECT|g" "$DEST/arch/DECISIONS.md"  2>/dev/null || true
sed -i "s|{{PROJECT}}|$PROJECT|g" "$DEST/runbooks/HOW_TO.md" 2>/dev/null || true
bash "$LOG_SRC/on_scaffold.sh" "$PROJECT" "$DEST" "$TS"
echo "--- docs scaffold done: $DEST"
