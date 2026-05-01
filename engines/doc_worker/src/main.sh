#!/bin/bash
PROJECT="$1"; PROJECT_ROOT="$2"; EVENT="$3"
[ -z "$PROJECT" ]      && echo "usage: main.sh <project> <project_root> <event>" && exit 1
[ -z "$PROJECT_ROOT" ] && echo "usage: main.sh <project> <project_root> <event>" && exit 1
[ -z "$EVENT" ]        && echo "usage: main.sh <project> <project_root> <event>" && exit 1
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
case "$EVENT" in
  build_done)
    echo "[$PROJECT] doc_worker: build_done → regenerating ref/"
    bash "$SELF_DIR/gen_ref.sh" "$PROJECT" "$PROJECT_ROOT" "$TS"
    ;;
  dep_install)
    DEP="$4"; MANAGER="$5"
    echo "[$PROJECT] doc_worker: dep_install → $DEP ($MANAGER)"
    bash "$SELF_DIR/watch_deps.sh" "$PROJECT" "$PROJECT_ROOT" "$DEP" "$MANAGER" "$TS"
    ;;
  session_open)
    echo "[$PROJECT] doc_worker: session_open"
    bash "$SELF_DIR/session_open.sh" "$PROJECT" "$PROJECT_ROOT" "$TS"
    ;;
  session_close)
    START_TS="$4"
    echo "[$PROJECT] doc_worker: session_close"
    bash "$SELF_DIR/session_close.sh" "$PROJECT" "$PROJECT_ROOT" "$START_TS" "$TS"
    ;;
  *)
    echo "[$PROJECT] doc_worker: unknown event: $EVENT"
    exit 1
    ;;
esac
