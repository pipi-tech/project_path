#!/bin/bash
# WHAT:  Captures pip freeze snapshot after an install
# WIRES: Called by functions/dep_wrappers.sh → writes to data/log/dep/input/after/
# WHY:   Before/after snapshots enable diff_deps to detect exactly what changed

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../.." && pwd)"

PROJECT="$1"
TS="$2"
DIR="$PTH_ROOT/data/log/dep/input/after"
mkdir -p "$DIR"

VENV_PIP=$(which pip)
SITE=$(python3 -m site --user-site 2>/dev/null)
VENV_SITE=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))" 2>/dev/null)

echo "project=$PROJECT" > "$DIR/$TS.txt"
echo "ts=$TS" >> "$DIR/$TS.txt"
echo "user=$USER" >> "$DIR/$TS.txt"
echo "pip=$VENV_PIP" >> "$DIR/$TS.txt"
echo "site=$VENV_SITE" >> "$DIR/$TS.txt"
echo "--- pip freeze ---" >> "$DIR/$TS.txt"
$VENV_PIP freeze 2>/dev/null >> "$DIR/$TS.txt"
echo "--- tree site-packages ---" >> "$DIR/$TS.txt"
tree "$VENV_SITE" --noreport -L 1 2>/dev/null >> "$DIR/$TS.txt"
tree "$SITE" --noreport -L 1 2>/dev/null >> "$DIR/$TS.txt"
