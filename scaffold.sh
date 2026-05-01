#!/bin/bash
BASE=~/project/project_path/data

dirs=(
  log/terminal/input
  log/terminal/src
  log/terminal/output
  main/input
  main/src
  main/output
  tui/input
  tui/src
  tui/output
  cli/input
  cli/src
  cli/output
  config/input
  config/src
  config/output
)

for d in "${dirs[@]}"; do
  mkdir -p "$BASE/$d"
  echo "created: $BASE/$d"
done

echo "---"
echo "done"
