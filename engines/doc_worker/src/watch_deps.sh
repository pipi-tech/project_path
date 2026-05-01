#!/bin/bash
PROJECT="$1"; PROJECT_ROOT="$2"; DEP="$3"; MANAGER="$4"; TS="$5"
[ -z "$PROJECT" ]      && echo "no project" && exit 1
[ -z "$PROJECT_ROOT" ] && echo "no project root" && exit 1
[ -z "$DEP" ]          && echo "no dep" && exit 1
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PP_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"
LOG_SRC="$PP_ROOT/data/log/doc/src"
CHANGELOG="$PROJECT_ROOT/docs/log/changelog.txt"
mkdir -p "$(dirname "$CHANGELOG")"
if [ ! -f "$CHANGELOG" ]; then
  cat > "$CHANGELOG" << HEADER
# $PROJECT — dep changelog
# auto-maintained by doc_worker/watch_deps.sh
# format: timestamp | manager | dep | action
HEADER
fi
echo "$TS | ${MANAGER:-unknown} | $DEP | installed" >> "$CHANGELOG"
echo "[$PROJECT] changelog: $DEP recorded"
bash "$LOG_SRC/on_dep_watch.sh" "$PROJECT" "$DEP" "${MANAGER:-unknown}" "installed" "$TS"
