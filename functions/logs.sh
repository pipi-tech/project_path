#!/bin/bash
clearLogs() {
  local base=~/project/project_path/data/log
  for domain in "$base"/*/; do
    if [ -d "$domain/input" ]; then
      for folder in "$domain/input"/*/; do
        [ -d "$folder" ] && rm -rf "$folder"/* 2>/dev/null
      done
    fi
  done
  echo "logs cleared"
}

tailLogs() {
  watch -n 1 '
    for domain in ~/project/project_path/data/log/*/; do
      name=$(basename "$domain")
      echo "=== $name ==="
      find "$domain/input" -name "*.txt" 2>/dev/null | xargs ls -lt 2>/dev/null | head -3
    done
  '
}

watchDeps() {
  local project="${1:-$(basename $(pwd))}"
  echo "watching deps for: $project"
  bash ~/project/project_path/data/log/dep/src/watch_silent.sh "$project" &
  echo "watcher pid: $!"
  echo "$!" > /tmp/dep_watcher.pid
}

stopWatchDeps() {
  if [ -f /tmp/dep_watcher.pid ]; then
    kill $(cat /tmp/dep_watcher.pid) 2>/dev/null
    rm /tmp/dep_watcher.pid
    echo "dep watcher stopped"
  fi
}
