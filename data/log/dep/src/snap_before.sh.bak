#!/bin/bash
PROJECT="$1"
TS="$2"
DIR=~/project/project_path/data/log/dep/input/before
mkdir -p "$DIR"

VENV_PIP=$(which pip)
SITE=$(python3 -m site --user-site 2>/dev/null)
VENV_SITE=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))" 2>/dev/null)

echo "project=$PROJECT" > "$DIR/$TS.txt"
echo "ts=$TS" >> "$DIR/$TS.txt"
echo "user=$USER" >> "$DIR/$TS.txt"
echo "pip=$VENV_PIP" >> "$DIR/$TS.txt"
echo "site=$VENV_SITE" >> "$DIR/$TS.txt"
echo "--- pip freeze ---" >> "$DIR/$TS.txt"
$VENV_PIP freeze 2>/dev/null >> "$DIR/$TS.txt"
echo "--- tree site-packages ---" >> "$DIR/$TS.txt"
tree "$VENV_SITE" --noreport -L 1 2>/dev/null >> "$DIR/$TS.txt"
tree "$SITE" --noreport -L 1 2>/dev/null >> "$DIR/$TS.txt"
