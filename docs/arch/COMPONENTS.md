# project_path — component design

Design session. Four work streams, ordered by dependency.
Read docs/axioms.md first — every decision here follows from those three lenses.

---

## Work stream 1: LDIDC rename

**What changes:**

| Old path        | New path         | Why                                      |
|-----------------|------------------|------------------------------------------|
| `engines/`      | `logic/`         | engines is impl detail; logic is the role |
| `functions/`    | `interface/shell/`| these are the sourced shell API          |
| `cmd/builder/`  | `interface/builder/` | thin wrappers — interface layer        |
| `cmd/cli/`      | `interface/cli/` | CLI output tools — interface layer       |
| `cmd/dep/`      | `interface/dep/` | dep snap/diff wrappers                   |
| `cmd/combine.sh`| `interface/combine.sh` |                                    |
| `cmd/tui/`      | `display/`       | TUI is pure display, owns no state       |
| `cmd/config/`   | `config/`        | declarative setup scripts                |
| `data/`         | `data/`          | unchanged — already correct              |
| `docs/`         | `docs/`          | unchanged                                |

**What stays at root:** `functions.sh` (the sourced entry point), `scaffold.sh`, `project.toml`, `.bashrc_ext`, `tests/`.

**functions.sh** becomes the bootstrap shim that sources `interface/shell/*.sh` instead of `functions/*.sh`. Name stays `functions.sh` — it is the well-known entry point in every user's `.bashrc`.

**Execution order:**
1. `git mv` each directory
2. bulk sed: `s|/engines/|/logic/|g`, `s|/functions/|/interface/shell/|g`, `s|/cmd/tui/|/display/|g`, `s|/cmd/config/|/config/|g`, `s|/cmd/builder/|/interface/builder/|g`, `s|/cmd/cli/|/interface/cli/|g`, `s|/cmd/dep/|/interface/dep/|g`
3. Update `functions.sh` source loop
4. Update all SELF_DIR level counts (display/ is now 2 levels from PTH_ROOT, not 3)
5. Run all 4 tests
6. Update docs, README, structure.txt snapshot

**Risk:** the `data/log/*/src/*.sh` scripts use relative `$SELF_DIR/../input/<event>` — they don't reference logic/ or interface/ at all, so they are unaffected.

---

## Work stream 2: docs/axioms.md

Done. See `docs/axioms.md`.

CLAUDE.md `@docs/axioms.md` reference now resolves.

---

## Work stream 3: recursive doc parser

### What it reads

Every `.sh` and `.py` file in the repo (excluding `data/`, `.git`, `__pycache__`, `.venv`) that has a header block in the form:

```bash
# WHAT:  one-line description of what this file does
# WIRES: caller → this → callee (call chain context)
# WHY:   the non-obvious reason this exists
```

Optionally, each directory can contain a `_dir.md` with the same three fields at the directory level (manually written, not generated).

### What it outputs

Three files, all in `docs/ref/`:

**`docs/ref/flat.md`** — current gen_ref behavior, extended to all scripts not just `src/`.

**`docs/ref/tree.md`** — hierarchical rollup:

```
# logic/                    ← folder WHAT from _dir.md or synthesized
  ## logic/builder/         ← folder WHAT
    ### build.sh            ← file WHAT + WIRES + WHY
    ### drift.sh
  ## logic/doc_worker/
    ### main.sh
  ...
# interface/
  ## interface/shell/
    ### builder.sh
    ...
```

**`docs/ref/wires.md`** — extracted call graph from all WIRES lines:

```
cmd/builder/build.sh → logic/builder/src/build.sh → logic/builder/src/read_toml.sh
                                                   → logic/builder/src/stamp_folders.sh
                                                   → logic/builder/src/register.sh
```

This is a flat list of `A → B` edges, one per WIRES annotation. Useful for dependency analysis and for catching when a WIRES claim is wrong (the file it claims to call doesn't exist).

### Parser design

Single script: `logic/doc_worker/src/parse_tree.sh`

```
parse_tree.sh [root]
  for each dir in root (depth-first):
    if _dir.md exists: read WHAT/WIRES/WHY from it
    for each .sh/.py in dir:
      extract WHAT/WHY/WIRES from header
      emit to flat.md, tree.md, wires.md
    emit folder entry to tree.md
```

The parser is called by the existing `doc ref` command as a second pass after `gen_ref.sh`.

### WIRES validation

A second script `logic/doc_worker/src/validate_wires.sh`:
- Parse all `# WIRES:` lines
- Extract file names from arrows (`→`)
- Check each named file exists in PTH_ROOT
- Report broken wires as warnings (not errors — they may reference future files)

### Key design constraint

The parser must be idempotent. Running it twice produces identical output. Generated files begin with a header marking them as auto-generated so editors know not to hand-edit them.

---

## Work stream 4: Merkle hash log

### Problem

Every event in `data/log/<domain>/input/<event>/<timestamp>.txt` is currently independent. You cannot tell if an event was tampered with, when exactly in a session it occurred relative to other domains, or what the "state of the system" was at any point in time.

### Structure

Each domain maintains a **chain** — a linked list of event hashes:

```
data/log/<domain>/
  input/
    build_done/
      2026-05-11_10-00-01.txt     ← event content
      2026-05-11_10-00-01.hash    ← SHA256(content + prev_hash)
  head.hash                       ← SHA256 of latest event in this domain
```

The **session hash** is:
```
SHA256(builder.head + doc.head + registry.head + dep.head + terminal.head + ...)
```

Computed at `session_close` and written to the session log entry. This is the "session hash" from v1Goal.txt — it is the root of the Merkle tree across all domain chains for that session.

### Components to build

**`logic/log_engine/src/hash_event.sh`**
```
hash_event.sh <domain> <event_file>
  prev=$(cat data/log/<domain>/head.hash 2>/dev/null || echo "0000...000")
  content=$(cat <event_file>)
  hash=$(echo "$prev$content" | sha256sum | awk '{print $1}')
  echo "$hash" > "<event_file>.hash"
  echo "$hash" > "data/log/<domain>/head.hash"
```

Called by every `data/log/<domain>/src/*.sh` after writing the event file.

**`logic/log_engine/src/session_hash.sh`**
```
session_hash.sh
  concat all domain head.hash values (sorted by domain name)
  SHA256 of that concat = session hash
  return it
```

Called by `doc_worker/src/session_close.sh` to embed the session hash in the closing log entry.

**`logic/log_engine/src/verify_chain.sh`**
```
verify_chain.sh [domain]
  walk all event files in order (by timestamp)
  recompute each hash from content + prev
  compare against stored .hash sidecar
  report any mismatches
```

Useful for `drift` and future audit commands.

**`data/log/<domain>/head.hash`**
One file per domain. Written atomically (write to tmp, mv) to avoid partial writes.

### Integration points

- Every `data/log/<domain>/src/*.sh` calls `hash_event.sh` after writing its event file
- `engines/doc_worker/src/session_close.sh` calls `session_hash.sh` and embeds the result
- `session show` command reads the session's closing entry to display the hash
- `drift` check can compare current chain tip vs last-known-good stored in `project.toml [fingerprint]`

### What this gives you

- **Session hash** (v1Goal.txt ✗ → ✅): a single SHA256 that represents everything that happened in a session
- **Tamper detection**: you can verify no log entry was edited after the fact
- **Cross-session diff**: compare two session hashes to know if anything changed
- **Foundation for the snap engine**: a snapshot is a set of (domain, head.hash) pairs at a point in time

---

## Build order

These four work streams have dependencies:

```
axioms.md        ← done, no deps
LDIDC rename     ← no deps, but do first (changes all paths)
  ↓
doc parser       ← depends on LDIDC being stable (paths in WIRES references)
  ↓
Merkle hash      ← depends on nothing but benefits from LDIDC (logic/ paths are cleaner)
```

Recommended sequence:

1. **LDIDC rename** — one big mechanical pass, all tests must pass before moving on
2. **Merkle hash** — add `hash_event.sh`, wire into existing `data/log/*/src/*.sh`, add `session_hash.sh` to `session_close.sh`
3. **Doc parser** — build `parse_tree.sh`, add `_dir.md` files to each directory, wire into `doc ref`
4. **axioms.md** — done ✅

---

## Open v1Goal items and how they map

| Goal              | Status  | Component                                          |
|-------------------|---------|----------------------------------------------------|
| session hash      | design  | Merkle log → `session_hash.sh` at session_close   |
| clearLogs all     | partial | `functions/logs.sh` clearLogs needs `--all` flag  |
| container reg     | ✗       | `logic/network/src/container_reg.sh` — new engine |
| enter (remote)    | ✗       | `interface/shell/remote.sh` + ssh session wrapper  |
| state engine      | stub    | `logic/state_engine/src/main.sh` needs transitions |
| snap engine       | ✗       | depends on Merkle hash being in place first        |
| tests             | partial | 4 tests exist; need engine + interface unit tests  |
