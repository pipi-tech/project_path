#!/bin/bash
# WHAT:  Silent dep watcher — monitors site-packages for installs that bypass pip wrapper
# WIRES: Called by functions/logs.sh (watchDeps) → writes to data/log/dep/input/silent/
# WHY:   Catches silent installs that don't go through the pip wrapper function

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../.." && pwd)"

PROJECT="${1:-unknown}"
SILENT_DIR="$PTH_ROOT/data/log/dep/input/silent"
mkdir -p "$SILENT_DIR"

USER_SITE=$(python3 -m site --user-site 2>/dev/null)
VENV_SITE=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))" 2>/dev/null)
LOCAL_SITE="$HOME/.local/lib/python3.12/site-packages"

watch_path() {
  local path="$1"
  [ ! -d "$path" ] && return
  echo "watching: $path"
  inotifywait -m -r -e create -e moved_to \
    --format '%T %e %w%f' \
    --timefmt '%Y-%m-%d_%H-%M-%S' \
    "$path" 2>/dev/null \
  | while read -r ts event filepath; do
      pkg=$(basename "$filepath" | sed 's/-[0-9].*//' | sed 's/\.dist-info//' | sed 's/\.egg-info//')
      [ -z "$pkg" ] && continue
      [[ "$pkg" == *"__pycache__"* ]] && continue
      TS=$(date '+%Y-%m-%d_%H-%M-%S')
      echo "project=$PROJECT"   > "$SILENT_DIR/${TS}_${pkg}.txt"
      echo "ts=$TS"            >> "$SILENT_DIR/${TS}_${pkg}.txt"
      echo "event=$event"      >> "$SILENT_DIR/${TS}_${pkg}.txt"
      echo "package=$pkg"      >> "$SILENT_DIR/${TS}_${pkg}.txt"
      echo "path=$filepath"    >> "$SILENT_DIR/${TS}_${pkg}.txt"
      echo "user=$USER"        >> "$SILENT_DIR/${TS}_${pkg}.txt"
      echo "source=silent"     >> "$SILENT_DIR/${TS}_${pkg}.txt"
      echo "site=$path"        >> "$SILENT_DIR/${TS}_${pkg}.txt"
    done
}

watch_path "$LOCAL_SITE" &
watch_path "$USER_SITE"  &
watch_path "$VENV_SITE"  &
wait
