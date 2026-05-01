#!/bin/bash
CMD_CONFIG=~/project/project_path/cmd/config

domains() {
  local cmd="${1:-show}"
  local toml="${2:-$(pwd)/project.toml}"
  case "$cmd" in
    set)  bash "$CMD_CONFIG/set_log_domains.sh" "$toml" ;;
    show) grep "^active" "$toml" ;;
    types) cat "$CMD_CONFIG/type_registry.conf" ;;
    add-type)
      [ -z "$2" ] || [ -z "$3" ] && echo "usage: domains add-type <type> <domains>" && return 1
      echo "$2:$3" >> "$CMD_CONFIG/type_registry.conf"
      echo "added: $2 → $3"
      ;;
    *) echo "usage: domains [set|show|types|add-type]" ;;
  esac
}

migrate() {
  bash "$CMD_CONFIG/migrate_toml.sh" "${1:-$(pwd)/project.toml}"
}

classify() {
  local manager="${1:-pip}"
  local toml="${2:-$(pwd)/project.toml}"
  bash "$CMD_CONFIG/classify_deps.sh" "$toml" "$manager"
}

onboard() {
  bash "$CMD_CONFIG/onboard_deps.sh" "${1:-$(pwd)}"
}

pkg_managers() {
  local cmd="${1:-list}"
  case "$cmd" in
    list)
      echo "=== package managers ==="
      echo ""
      echo "pip:"
      pip list 2>/dev/null | tail -n +3 | wc -l | xargs echo "  packages:"
      which pip 2>/dev/null | xargs echo "  path:"
      echo ""
      echo "apt (manual):"
      apt-mark showmanual 2>/dev/null | wc -l | xargs echo "  packages:"
      echo ""
      echo "npm:"
      if command -v npm &>/dev/null; then
        npm list -g --depth=0 2>/dev/null | grep -c "^[├└]" | xargs echo "  packages:"
        which npm | xargs echo "  path:"
      else
        echo "  not installed"
      fi
      echo ""
      echo "cargo:"
      if command -v cargo &>/dev/null; then
        cargo install --list 2>/dev/null | grep -v "^    " | grep -v "^$" | wc -l | xargs echo "  packages:"
        which cargo | xargs echo "  path:"
      else
        echo "  not installed"
      fi
      echo ""
      echo "flatpak:"
      flatpak list 2>/dev/null | wc -l | xargs echo "  packages:"
      echo ""
      echo "snap:"
      snap list 2>/dev/null | tail -n +2 | wc -l | xargs echo "  packages:"
      echo ""
      echo "conda:"
      if command -v conda &>/dev/null && [ -f "environment.yml" ]; then
        conda list 2>/dev/null | tail -n +4 | wc -l | xargs echo "  packages:"
        which conda | xargs echo "  path:"
      else
        echo "  not active (no environment.yml)"
      fi
      ;;
    detect)
      local toml="${2:-$(pwd)/project.toml}"
      echo "=== detecting: $(basename $(pwd)) ==="
      MANAGERS=""
      [ -f ".venv/bin/pip" ]                                   && MANAGERS="$MANAGERS pip"   && echo "  ✓ pip"
      command -v cargo &>/dev/null && [ -f "Cargo.toml" ]      && MANAGERS="$MANAGERS cargo" && echo "  ✓ cargo"
      command -v npm &>/dev/null   && [ -f "package.json" ]    && MANAGERS="$MANAGERS npm"   && echo "  ✓ npm"
      [ -f "pyproject.toml" ]                                  && MANAGERS="$MANAGERS uv"    && echo "  ✓ uv"
      command -v conda &>/dev/null && [ -f "environment.yml" ] && MANAGERS="$MANAGERS conda" && echo "  ✓ conda"
      MANAGERS=$(echo "$MANAGERS" | xargs)
      if [ -f "$toml" ] && grep -q "^\[managers\]" "$toml"; then
        sed -i "s|^active.*=.*|active      = \"$MANAGERS\"|" "$toml"
        echo "  toml updated: $MANAGERS"
      fi
      ;;
    snapshot)
      local project=$(basename $(pwd))
      local TS=$(date '+%Y-%m-%d_%H-%M-%S')
      local MGR_LOG=~/project/project_path/data/log/dep/input/managers
      mkdir -p "$MGR_LOG"
      {
        echo "project=$project"
        echo "ts=$TS"
        echo "user=$USER"
        echo "node=$(hostname)"
        echo "pip=$(pip list 2>/dev/null | tail -n +3 | wc -l)"
        echo "apt=$(apt-mark showmanual 2>/dev/null | wc -l)"
        echo "flatpak=$(flatpak list 2>/dev/null | wc -l)"
        echo "snap=$(snap list 2>/dev/null | tail -n +2 | wc -l)"
      } > "$MGR_LOG/$TS.txt"
      echo "snapshot: $MGR_LOG/$TS.txt"
      cat "$MGR_LOG/$TS.txt"
      ;;
    classify)
      classify "${2:-pip}"
      ;;
    *)
      echo "usage: pkg_managers [list|detect|snapshot|classify <mgr>]"
      ;;
  esac
}
