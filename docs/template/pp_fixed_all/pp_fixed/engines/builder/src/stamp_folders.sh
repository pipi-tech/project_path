#!/bin/bash
# WHAT:  Creates standard project folder structure src/ input/ output/ tests/ docs/
# WIRES: Called by engines/builder/src/build.sh → creates dirs under /root/project/
# WHY:   Consistent project anatomy — every project gets the same base structure on creation
[ -z "$PROJECT_NAME" ] && echo "no project name" && exit 1
BASE="$HOME/project/$PROJECT_NAME"
mkdir -p "$BASE"/{src,input,output,tests,docs}
echo "stamped: $BASE"
