#!/bin/bash
PROJECT_ROOT="${1:-$(pwd)}"
CLASSES=~/project/project_path/cmd/config/pkg_classes.conf
TARGET="$PROJECT_ROOT/.dep_classes.conf"

[ ! -f "$CLASSES" ] && echo "no base pkg_classes.conf found" && exit 1

cp "$CLASSES" "$TARGET"
echo "onboarded dep classes → $TARGET"
echo "packages pre-classified: $(grep -v '^#' $TARGET | grep -v '^$' | wc -l)"
