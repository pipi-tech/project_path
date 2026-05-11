> **Status: early access — functional but rough edges exist. PRs welcome.**

# project_path

A shell-based project runtime. It turns directories into addressable, trackable nodes with dependency management, fingerprinting, session logging, and auto-documentation.

**The core idea:** every project you work on has a lifecycle — creation, setup, development, drift, history. project_path makes that lifecycle explicit and auditable, entirely from your terminal.

### [→ Philosophy](docs/PHILOSOPHY.md)

---

## Install

```bash
git clone https://github.com/pipi-tech/project_path.git
cd project_path
bash scaffold.sh
echo "source $(pwd)/functions.sh" >> ~/.bashrc
source ~/.bashrc
```

That's it. No package manager. No global install. Just bash.

### Platform support

| Platform | Status | Notes |
|---|---|---|
| Linux (Ubuntu/Debian) | ✅ Full | Primary target |
| macOS | ⚠️ Partial | `brew install bash` required for bash 5+; no `apt` |
| WSL2 | ✅ Full | Behaves like Linux |
| Windows native | ❌ Not supported | Use WSL2 |

---

## Architecture

Four layers. Each has one job.

```
functions/       ← what you type (the user-facing API)
    ↓
cmd/             ← thin wrappers — stable interface layer
    ↓
engines/         ← where logic runs (builder, doc_worker, drift, log, state, network)
    ↓
data/            ← registry, logs, templates (append-only, never edited directly)
```

**functions/** — shell functions you call directly. Validate input, delegate down.  
**cmd/** — stable interface scripts. engines/ can change without functions/ knowing.  
**engines/** — actual execution. Each engine owns a domain with `input/`, `src/`, `output/`.  
**data/** — `registry.conf` (identity), `registry.txt` (history), `log/` (event streams).

---

## Quick start

```bash
# Create a new project
new myproject

# Enter a project (activates venv, opens session)
proj myproject

# View all registered projects
proj

# Build pipeline (reads project.toml, installs deps, fingerprints, registers)
build
```

---

## Commands

### Projects
```bash
proj                        # list all projects
proj <name>                 # enter project — activates venv, opens session
new <name>                  # create new project — opens editor, builds, enters
```

### Registry
```bash
reg list                    # all registered projects
reg show <name>             # single project details
reg history [name]          # full or filtered activity log
reg remove <name>           # unregister
```

### Build + Environment
```bash
build [toml]                # full pipeline: read → stamp → deps → fingerprint → register
fingerprint [toml]          # generate/update fingerprint hash
drift [toml]                # compare stored vs current hash
deps compare [toml]         # declared vs installed
deps add <pkg> [toml]       # add + install package
deps add-only <pkg> [toml]  # add to toml, skip install
```

### Dependencies
```bash
classify [toml] [mgr]       # classify packages by category (nlp/audio/cli/etc)
migrate [toml]              # create/migrate project.toml from current pip state
onboard [toml] [mgr]        # copy dep classification map into project
```

### Documentation
```bash
doc init [name] [root]      # scaffold docs + gen ref + open session
doc ref [name] [root]       # regenerate ref/SCRIPTS.md from @doc annotations
doc session open/close/show # session boundary management
doc deps <dep> <mgr>        # log a dep install to changelog
doc log [name]              # list session files
doc edit [name]             # open latest session in editor
doc migrate                 # doc init all registered projects
```

### Sessions + Logs
```bash
session show                # current session identity + hash
session history             # all past sessions
session find <hash>         # trace all activity for a hash across all domains
session active              # live and dead sessions
session clean               # remove dead session files
clearLogs                   # clear all log input folders
tailLogs                    # live tail of all log streams
```

### Templates
```bash
tpl update                  # snapshot current structure
tpl stamp <target>          # clone structure to target dir
tpl show                    # view structure snapshot
tpl tree                    # live tree of project_path
```

### Utilities
```bash
msrc                        # generate master source reference file
mlog                        # generate master log reference file
tui                         # launch TUI dashboard
```

---

## Log system

project_path's log system is one of its core pillars. It is the foundation for every audit feature — session tracking, drift detection, dep history, build tracing.

Every meaningful action emits a structured event to `data/log/<domain>/input/`. These are plain text files, one per event, in `key=value` format. The structure is append-only — nothing is deleted, only accumulated.

**Log domains:**

| Domain | What it records |
|---|---|
| `terminal/` | Who ran what, on which node, in which session |
| `builder/` | Every build step — start, each step, done, drift |
| `registry/` | Every project register, update, access, drift event |
| `dep/` | Before/after pip freeze snapshots, diffs, silent installs |
| `doc/` | Session open/close, ref generation, dep changelog |

**Why this matters:**
- Every `session find <hash>` query works because terminal, dep, and registry events all carry the same session hash
- Drift detection works because `builder/` and `registry/` events carry fingerprint hashes
- `mlog` works because every domain has a consistent `input/` layout

**What you can do with the log data:**
```bash
# Find everything that happened in a session
session find <hash>

# See all deps installed for a project over time
grep "project=myproject" data/log/dep/input/install/*.txt

# See every build across all projects
ls -lt data/log/builder/input/build_done/

# Cross-reference a fingerprint hash to when it was first created
grep "<hash>" data/log/registry/input/registered/*.txt
```

The log system is intentionally simple — plain files, plain text, queryable with grep and awk. No database required.

---

## project.toml

Every project has a `project.toml`. Run `migrate` to generate one from your current state, or `new` to create one interactively.

```toml
[project]
name        = "myproject"
version     = "0.1.0"
state       = "active"
author      = "you"

[type]
domain      = "backend"
subtype     = "api"

[runtime]
env         = "dev"
venv        = ".venv"

[managers]
active      = "pip"
pip         = "true"

[dependencies]
python      = "3.12.3"
requires    = ["requests", "click"]
dev         = ["pytest"]

[fingerprint]
hash            = ""
generated_at    = ""
generated_by    = ""

[log]
active = ["terminal", "registry", "dep"]

[registry]
project_id  = ""
node        = ""
```

---

## Annotate your scripts for auto-docs

The `doc ref` command reads `@` annotations from your `src/` scripts and generates `docs/ref/SCRIPTS.md` automatically.

```bash
# @doc    Does the thing
# @usage  my_script.sh <input>
# @input  path to input file
# @output path to output file
# @domain builder
# @state  modifies registry.conf
# @tier   engine
```

---

## Tests

```bash
bash tests/test_portability.sh          # PTH_ROOT resolves correctly
bash tests/test_scaffold.sh             # data/log/ structure exists
bash tests/test_no_hardcoded_paths.sh   # no ~/project/project_path in any script
bash tests/test_no_duplicate_builder.sh # builder/src/ removed, engines/ is canonical
bash tests/test_log_write.sh            # log domains are writable
```

---

## Contributing

1. Fork → branch → PR
2. Run all tests before opening a PR
3. Add `# WHAT / # WIRES / # WHY` headers to any new scripts
4. If you add a new log domain, add the directory to `scaffold.sh`

---

## Status

**Version:** 0.1.0 — early, functional, rough edges  
**Primary target:** Linux (Ubuntu/Debian)  
**Maintained by:** pipi-tech
