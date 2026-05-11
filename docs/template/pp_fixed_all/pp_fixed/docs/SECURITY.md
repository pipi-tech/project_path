# Security Notes — project_path

This document covers known attack surfaces, what we do about them, and what is safe for public use.

---

## What is safe to publish as-is

- All shell scripts after the path portability fix
- The log domain structure
- The registry format
- The TOML schema
- The doc_worker and builder engines

---

## Known attack surfaces and mitigations

### 1. `eval` in `functions/dep_wrappers.sh`

**What it does:**
`_dep_wrap` builds a command string from `MANAGER + PACKAGE + args` and calls `eval "$CMD"`.

**The risk:**
If `PACKAGE` contains shell metacharacters (`;`, `$(...)`, backticks), they will be interpreted by bash. Example:
```bash
pip install "requests; rm -rf ~"   # would execute rm -rf ~
```

**Mitigation in place:**
The package string comes through `"${*:2}"` which preserves quoting from the caller. If the user types the package name directly, their shell processes it before it reaches `_dep_wrap`, so injection would require the user to attack themselves.

**Mitigation needed before wide distribution:**
Replace `eval "$CMD"` with direct execution:
```bash
# Instead of: eval "$CMD"
command "$MANAGER" "$@"
```
This eliminates eval entirely. The wrapper just calls the real command with original args, no string interpolation.

**Severity:** Low in personal use. Medium in shared/multi-user environments.

---

### 2. `sed -i` with `$PROJECT_NAME` in `register.sh`

**What it does:**
```bash
sed -i "s|^$PROJECT_NAME:.*|$PROJECT_NAME:...|" "$REG_CONF"
```

**The risk:**
If `PROJECT_NAME` contains sed metacharacters (`|`, `\`, `.`, `*`), the pattern breaks or could match unintended lines.

**Mitigation:**
Project names come from `project.toml` which is a file the user controls. This is self-inflicted at worst.

**Hardening option:**
```bash
# Escape PROJECT_NAME before use in sed
SAFE_NAME=$(printf '%s\n' "$PROJECT_NAME" | sed 's/[[\.*^$()+?{|]/\\&/g')
sed -i "s|^${SAFE_NAME}:.*|${PROJECT_NAME}:...|" "$REG_CONF"
```

**Severity:** Very low — self-inflicted only.

---

### 3. `pip install $DEPS` (unquoted) in `install_deps.sh`

**What it does:**
```bash
DEPS=$(grep "^requires" "$TOML" | ...)
pip install $DEPS --break-system-packages
```

**The risk:**
`$DEPS` is unquoted, so word splitting applies. Package names with spaces (unusual but possible) could be split incorrectly. More importantly, `--break-system-packages` is always passed, which modifies the system Python environment.

**Mitigation:**
- `--break-system-packages` is intentional and documented
- Package names with spaces are not valid pip package names
- The DEPS string comes from a TOML file the user controls

**Hardening option:**
Read each dep individually and install in a loop with proper quoting.

**Severity:** Very low — user controls the TOML.

---

### 4. `watch_silent.sh` uses `inotifywait` on site-packages

**What it does:**
Watches Python site-packages directories for new files and logs them.

**The risk:**
If a malicious package installs a file with a name that contains shell metacharacters, and that filename gets interpolated into the log path, it could write to an unexpected location.

**Mitigation in place:**
The package name is cleaned with `sed` before use:
```bash
pkg=$(basename "$filepath" | sed 's/-[0-9].*//' | sed 's/\.dist-info//' ...)
```

**Hardening option:**
Add alphanumeric-only filter:
```bash
pkg=$(echo "$pkg" | tr -cd 'a-zA-Z0-9_-')
[ -z "$pkg" ] && continue
```

**Severity:** Low.

---

### 5. Registry contains project paths that expand `~`

**What it does:**
`registry.conf` stores paths like `~/project/myproject`. Scripts expand these with `sed "s|~|$HOME|"`.

**The risk:**
If `$HOME` itself contains a pipe character or other sed metacharacter, the substitution breaks.

**Mitigation:**
`$HOME` is set by the OS and extremely unlikely to contain metacharacters. Still worth noting.

**Severity:** Negligible.

---

### 6. No authentication or access control

project_path is a **local tool** designed for single-user use on a personal machine. It has no network exposure, no authentication layer, and no privilege escalation.

If you are considering running it in a multi-user environment or exposing any part of it over a network, treat it as untrusted and add appropriate controls.

---

## PII / data hygiene for public repo

The following data is **not** committed to the repo (via `.gitignore` and cleanup):

| What | Why excluded |
|---|---|
| `data/log/**/input/*.txt` | Contains usernames, hostnames, session hashes, timestamps |
| `data/log/**/output/*.txt` | Derived from above |
| `docs/log/session_*.txt` | Contains user, node, tty identity |
| `data/registry.conf` | Contains project paths and names |
| `data/registry.txt` | Contains full activity history with usernames |
| `data/MasterSCRText/` | Contains full source of all projects |
| `data/MasterLOGText/` | Contains full log history |

The shipped `registry.conf` and `registry.txt` are empty templates with comment headers only.

---

## What to do before a 1.0 release

1. Replace `eval "$CMD"` in `dep_wrappers.sh` with direct command execution
2. Add alphanumeric filter to package names in `watch_silent.sh`
3. Add `$PROJECT_NAME` sanitization in `register.sh`
4. Decide policy on `--break-system-packages` — document it prominently or make it configurable
5. Add a note in README about not using on shared/multi-user machines without review
