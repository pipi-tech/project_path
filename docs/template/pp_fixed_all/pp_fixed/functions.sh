# WHAT:  Entry point — resolves PTH_ROOT and sources all function modules
# WIRES: Sourced by ~/.bashrc → loads functions/*.sh → exposes all commands to terminal
# WHY:   Single source load — one line in .bashrc boots the entire system

export PTH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in "$PTH_ROOT/functions/"*.sh; do
  [ -f "$f" ] && source "$f"
done
