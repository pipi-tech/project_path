# doc worker — README
Template lives in: project_path/docs/
Spawns into:       <project>/docs/

---

## two layers
| folder    | who writes   | format | purpose                               |
|-----------|--------------|--------|---------------------------------------|
| arch/     | you          | .md    | decisions, invariants, open questions |
| runbooks/ | you          | .md    | how to run, operate, debug            |
| ref/      | doc worker   | .md    | auto-generated from .sh source files  |
| log/      | worker + you | .txt   | sessions auto-captured, you annotate  |

---

## doc worker fires on
- build_done     → regenerates ref/
- dep_install    → appends to log/changelog.txt
- session_open   → creates log/session_YYYY-MM-DD.txt
- session_close  → finalises session file

---

## wiring into build.sh
bash ~/project/project_path/docs/scaffold.sh "$PROJECT_NAME" "$PROJECT_ROOT"
bash ~/project/project_path/engines/doc_worker/src/main.sh \
     "$PROJECT_NAME" "$PROJECT_ROOT" "build_done"
