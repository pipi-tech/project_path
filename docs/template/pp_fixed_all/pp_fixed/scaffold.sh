#!/bin/bash
# WHAT:  First-run installer — creates data/log/ structure, detects OS, verifies environment
# WIRES: Run once after clone → writes to data/log/ → called manually, not by other scripts
# WHY:   Root installer — must be self-contained, cannot rely on PTH_ROOT being set yet

PTH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- OS detection ---
case "$(uname -s)" in
  Linux*)
    OS="linux"
    grep -qi microsoft /proc/version 2>/dev/null && OS="wsl"
    ;;
  Darwin*)
    OS="macos"
    ;;
  *)
    echo "unsupported OS: $(uname -s)"
    exit 1
    ;;
esac
echo "detected OS: $OS"

# --- data/log structure ---
BASE="$PTH_ROOT/data"
log_domains=(
  log/terminal/input/project
  log/terminal/input/terminal
  log/terminal/input/when
  log/terminal/input/who
  log/terminal/output
  log/terminal/src
  log/builder/input/build_done
  log/builder/input/build_start
  log/builder/input/build_step
  log/builder/input/dep_install
  log/builder/input/drift
  log/builder/output
  log/builder/src
  log/registry/input/accessed
  log/registry/input/drift
  log/registry/input/registered
  log/registry/input/updated
  log/registry/output
  log/registry/src
  log/dep/input/after
  log/dep/input/before
  log/dep/input/diff
  log/dep/input/install
  log/dep/input/managers
  log/dep/input/silent
  log/dep/output
  log/dep/src
  log/cli/input
  log/cli/output
  log/cli/src
  log/config/input
  log/config/output
  log/config/src
  log/main/input
  log/main/output
  log/main/src
  log/tui/input
  log/tui/output
  log/tui/src
  log/doc/input
  log/doc/output
  log/doc/src
)

for d in "${log_domains[@]}"; do
  mkdir -p "$BASE/$d"
  touch "$BASE/$d/.gitkeep"
done

echo "log structure created: $BASE/log/"

# --- OS-specific notes ---
if [ "$OS" = "macos" ]; then
  echo ""
  echo "macOS notes:"
  echo "  - apt commands will be skipped (not available)"
  echo "  - sha256sum is aliased to: shasum -a 256"
  echo "  - ensure bash 5+ is installed: brew install bash"
fi

echo "---"
echo "scaffold done — add to your shell:"
echo "  echo 'source $PTH_ROOT/functions.sh' >> ~/.bashrc"
echo "  source ~/.bashrc"
