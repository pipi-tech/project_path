#!/bin/bash
[ -z "$PROJECT_NAME" ] && echo "no project name" && exit 1
BASE="$HOME/project/$PROJECT_NAME"
mkdir -p "$BASE"/{src,input,output,tests,docs}
echo "stamped: $BASE"
