#!/bin/bash
PROJECT="$1"; PROJECT_ROOT="$2"; START_TS="$3"; END_TS="$4"
[ -z "$PROJECT" ]      && echo "no project" && exit 1
[ -z "$PROJECT_ROOT" ] && echo "no project root" && exit 1
[ -z "$START_TS" ]     && echo "no start ts" && exit 1
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PP_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"
LOG_SRC="$PP_ROOT/data/log/doc/src"
SESSION_FILE="$PROJECT_ROOT/docs/log/session_${START_TS}.txt"
END_TS="${END_TS:-$(date '+%Y-%m-%d_%H-%M-%S')}"
if [ ! -f "$SESSION_FILE" ]; then
  echo "[$PROJECT] session_close: file not found: $SESSION_FILE"
  exit 1
fi
START_EPOCH=$(date -d "${START_TS//_/ }" '+%s' 2>/dev/null || echo 0)
END_EPOCH=$(date -d "${END_TS//_/ }"   '+%s' 2>/dev/null || echo 0)
DURATION=$((END_EPOCH - START_EPOCH))
sed -i "s|closed: (filled by session_close.sh)|closed: $END_TS|" "$SESSION_FILE"
sed -i "s|duration: (filled by session_close.sh)|duration: ${DURATION}s|" "$SESSION_FILE"
echo "[$PROJECT] session closed: $SESSION_FILE (${DURATION}s)"
bash "$LOG_SRC/on_session_close.sh" "$PROJECT" "$SESSION_FILE" "$DURATION" "$END_TS"
