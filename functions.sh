for f in ~/project/project_path/functions/*.sh; do
  [ -f "$f" ] && source "$f"
done
