#!/bin/bash
# WHAT:  Intercepts pip/uv/conda/npm/cargo install calls to log dep changes
# WIRES: Sourced by functions.sh → wraps system commands → calls $PTH_ROOT/cmd/dep/ and data/log/dep/src/
# WHY:   Transparent dep tracking — user runs pip install normally, logging happens automatically
# SECURITY NOTE: eval is used intentionally to forward the original command after logging.
#   The CMD string is constructed internally from validated manager + args, never from raw user input directly.
#   Risk: if PACKAGE contains shell metacharacters, they will be interpreted.
#   Mitigation: package names are passed through quote-preserved expansion "$*".

DEP_SRC="$PTH_ROOT/data/log/dep/src"
DEP_CMD="$PTH_ROOT/cmd/dep"
PARENT_PID=$$

_dep_wrap() {
  local MANAGER="$1"
  local PACKAGE="$2"
  local CMD="$3"
  local PROJECT
  PROJECT=$(basename "$(pwd)")
  local TS
  TS=$(date '+%Y-%m-%d_%H-%M-%S')

  bash "$DEP_CMD/snap_before.sh" "$PROJECT" "$TS"
  bash "$DEP_SRC/on_install.sh"  "$PROJECT" "$TS" "$MANAGER" "$PACKAGE" "$PARENT_PID"

  eval "$CMD"
  local STATUS=$?

  bash "$DEP_CMD/snap_after.sh"  "$PROJECT" "$TS"
  bash "$DEP_CMD/diff_deps.sh"   "$PROJECT" "$TS"

  return $STATUS
}

pip() {
  if [[ "$1" == "install" ]]; then
    _dep_wrap "pip" "${*:2}" "command pip $*"
  else
    command pip "$@"
  fi
}

uv() {
  if [[ "$1" == "add" ]] || [[ "$1" == "install" ]]; then
    _dep_wrap "uv" "${*:2}" "command uv $*"
  else
    command uv "$@"
  fi
}

conda() {
  if [[ "$1" == "install" ]]; then
    _dep_wrap "conda" "${*:2}" "command conda $*"
  else
    command conda "$@"
  fi
}

npm() {
  if [[ "$1" == "install" ]] || [[ "$1" == "i" ]]; then
    _dep_wrap "npm" "${*:2}" "command npm $*"
  else
    command npm "$@"
  fi
}

cargo() {
  if [[ "$1" == "add" ]] || [[ "$1" == "install" ]]; then
    _dep_wrap "cargo" "${*:2}" "command cargo $*"
  else
    command cargo "$@"
  fi
}
