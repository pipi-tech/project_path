#!/bin/bash
TOML="${1:-$(pwd)/project.toml}"
CLASSES=~/project/project_path/cmd/config/pkg_classes.conf
MANAGER="${2:-pip}"
[ ! -f "$TOML" ] && echo "no project.toml found" && exit 1
[ ! -f "$CLASSES" ] && echo "no pkg_classes.conf found" && exit 1
CATEGORIES="nlp audio vision video analytical ml data http cli build runtime util async security db test dev system media other"
TMPDIR=$(mktemp -d)
get_category() { grep "^${1}:${2}:" "$CLASSES" 2>/dev/null | cut -d: -f3 | head -1; }
system_version() {
  case "$2" in
    pip)   pip show "$1" 2>/dev/null | grep "^Version:" | cut -d' ' -f2 ;;
    apt)   dpkg -l "$1" 2>/dev/null | grep "^ii" | awk '{print $3}' | head -1 ;;
    npm)   npm list -g "$1" 2>/dev/null | grep "$1" | grep -oP '@\K[0-9.]+' ;;
    cargo) cargo install --list 2>/dev/null | grep "^$1 " | grep -oP 'v\K[0-9.]+' ;;
  esac
}
get_manager_packages() {
  case "$1" in
    pip)   grep "^requires" "$TOML" | head -1 | cut -d'=' -f2 | tr -d '[]' | tr ',' '\n' | tr -d '"' | tr -d ' ' | grep -v '^$' | cut -d'=' -f1 ;;
    apt)   grep "^apt " "$TOML" | head -1 | cut -d'=' -f2 | tr -d '[]' | tr ',' '\n' | tr -d '"' | tr -d ' ' | grep -v '^$' ;;
    npm)   grep "^npm " "$TOML" | head -1 | cut -d'=' -f2 | tr -d '[]' | tr ',' '\n' | tr -d '"' | tr -d ' ' | grep -v '^$' ;;
    cargo) grep "^cargo " "$TOML" | head -1 | cut -d'=' -f2 | tr -d '[]' | tr ',' '\n' | tr -d '"' | tr -d ' ' | grep -v '^$' ;;
  esac
}
echo "classifying: $(basename $(pwd)) [$MANAGER]"
echo "---"
PKGS=$(get_manager_packages "$MANAGER")
if [ -z "$(echo $PKGS | tr -d ' \n')" ]; then
  echo "no $MANAGER packages in toml"
  rm -rf "$TMPDIR" && exit 0
fi
while IFS= read -r pkg; do
  [ -z "$pkg" ] && continue
  pkg=$(echo "$pkg" | tr -d ' ' | cut -d'=' -f1)
  [ -z "$pkg" ] && continue
  cat=$(get_category "$pkg" "$MANAGER")
  if [ -z "$cat" ]; then
    echo ""
    echo "❓ unknown: $pkg ($MANAGER)"
    echo "   [$CATEGORIES]"
    printf "   classify as: "
    read -r cat < /dev/tty
    [ -z "$cat" ] && cat="other"
    valid=0
    for c in $CATEGORIES; do [ "$cat" = "$c" ] && valid=1; done
    [ $valid -eq 0 ] && echo "   invalid — using other" && cat="other"
    echo "$pkg:$MANAGER:$cat" >> "$CLASSES"
    echo "   saved → $cat"
  fi
  ver=$(system_version "$pkg" "$MANAGER")
  if [ -n "$ver" ]; then
    echo "  ✓ $pkg==$ver → $cat"
    echo "\"$pkg==$ver\"" >> "$TMPDIR/$cat"
  else
    echo "  ↓ $pkg → $cat"
    echo "\"$pkg\"" >> "$TMPDIR/$cat"
  fi
done <<< "$PKGS"
echo ""
echo "--- writing to toml ---"
grep -n "^\[dependencies\.$MANAGER\." "$TOML" 2>/dev/null | cut -d: -f1 | sort -rn | while read -r ln; do
  end_ln=$(awk "NR>$ln && /^\[/{print NR; exit}" "$TOML")
  if [ -n "$end_ln" ]; then sed -i "${ln},$((end_ln-1))d" "$TOML"
  else sed -i "${ln},\$d" "$TOML"; fi
done
for cat in $CATEGORIES; do
  [ ! -f "$TMPDIR/$cat" ] && continue
  pkgs=$(grep -v '^$' "$TMPDIR/$cat" | tr '\n' ',' | sed 's/,$//')
  [ -z "$pkgs" ] && continue
  printf "\n[dependencies.%s.%s]\nrequires = [%s]\n" "$MANAGER" "$cat" "$pkgs" >> "$TOML"
  echo "  wrote: [dependencies.$MANAGER.$cat]"
done
TS=$(date '+%Y-%m-%d_%H-%M-%S')
MGR_LOG=~/project/project_path/data/log/dep/input/managers
mkdir -p "$MGR_LOG"
echo "project=$(basename $(pwd))" > "$MGR_LOG/$TS.txt"
echo "ts=$TS" >> "$MGR_LOG/$TS.txt"
echo "manager=$MANAGER" >> "$MGR_LOG/$TS.txt"
echo "user=$USER" >> "$MGR_LOG/$TS.txt"
rm -rf "$TMPDIR"
echo "done"
