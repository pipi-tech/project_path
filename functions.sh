PTH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PTH_ROOT

for f in "$PTH_ROOT/functions/"*.sh; do
  [ -f "$f" ] && source "$f"
done
