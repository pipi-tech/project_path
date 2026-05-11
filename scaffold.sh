#!/bin/bash
# WHAT:  Root installer — creates data/ directory tree for a fresh clone
# WIRES: Run once after cloning → creates data/log/ structure → user adds source line to ~/.bashrc
# WHY:   Root installer — must be self-contained, cannot rely on PTH_ROOT being set yet

PTH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="$PTH_ROOT/data"

dirs=(
  log/terminal/input/who
  log/terminal/input/when
  log/terminal/input/terminal
  log/terminal/input/project
  log/terminal/src
  log/terminal/output
  log/builder/input/build_start
  log/builder/input/build_step
  log/builder/input/build_done
  log/builder/input/dep_install
  log/builder/input/drift
  log/builder/src
  log/registry/input/registered
  log/registry/input/updated
  log/registry/input/accessed
  log/registry/input/drift
  log/registry/src
  log/dep/input/before
  log/dep/input/after
  log/dep/input/diff
  log/dep/input/install
  log/dep/input/managers
  log/dep/input/silent
  log/dep/src
  log/doc/input/session
  log/doc/input/ref
  log/doc/input/dep
  log/doc/input/scaffold
  log/doc/src
  log/MasterLOGText
  log/MasterSCRText
  log/MasterTree
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
  template
)

for d in "${dirs[@]}"; do
  mkdir -p "$BASE/$d"
done

# ensure engines/builder/input exists
mkdir -p "$PTH_ROOT/engines/builder/input"
[ ! -f "$PTH_ROOT/engines/builder/input/test.toml" ] && \
  cp "$PTH_ROOT/cmd/config/template/blank.toml" \
     "$PTH_ROOT/engines/builder/input/test.toml" 2>/dev/null || true

echo "---"
echo "scaffold done: $PTH_ROOT"
echo ""
echo "next step — add to ~/.bashrc:"
echo "  echo 'source $PTH_ROOT/functions.sh' >> ~/.bashrc"
echo "  source ~/.bashrc"
