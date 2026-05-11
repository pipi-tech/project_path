# project_path — axioms

Three lenses that govern every design decision in this codebase.
When they conflict, they rank in this order: Adversarial > OSI > LDIDC.

---

## 1. OSI: layers talk only to adjacent layers

The OSI model solved network reliability by making each layer ignorant of everything except the one directly below it. We apply the same discipline here.

No layer is allowed to reach across another layer. Interface calls Logic. Logic reads and writes Data. Display renders what Interface exposes. Config is read by Logic at startup and never touched at runtime. If you find yourself calling Logic from Display, or reading Data directly from Interface, a layer is missing or a responsibility has leaked.

```
Display   →  Interface  →  Logic  →  Data
                 ↑
              Config (read-only at startup)
```

This is not bureaucracy. It is the reason you can replace any one layer without touching the others.

---

## 2. LDIDC: the five layers of this system

| Layer     | Directory    | Responsibility                                      |
|-----------|--------------|-----------------------------------------------------|
| Logic     | `logic/`     | Engines — build, drift, log, doc, state, network   |
| Data      | `data/`      | Registry, logs, templates — append-only, no logic  |
| Interface | `interface/` | Shell API (sourced) + thin CLI wrappers             |
| Display   | `display/`   | TUI dashboard — renders state, never owns it        |
| Config    | `config/`    | TOML templates, domain setup, classification rules  |

**Layer contracts:**

- `logic/` owns all computation. It reads config once, reads/writes data, and emits structured events.
- `data/` is append-only by convention. Nothing deletes or edits log entries. The registry is a flat file, not a database.
- `interface/` is stateless. It validates user input, delegates to logic, and prints results. No business logic lives here.
- `display/` reads state from interface/logic via env and files. It never writes to data directly.
- `config/` is declarative. TOML files and shell config — no execution, no side effects.

---

## 3. Adversarial: every boundary is a trust boundary

Treat every function call, every env var, every file path, every argument as potentially wrong. Not because callers are malicious — because they are humans running code in environments you did not control.

Rules that follow from this:

**Fail loudly.** `exit 1` on bad input. Never silently continue. A silent failure is worse than a loud crash because you won't know where things went wrong.

**Validate at boundaries, not inside.** Check args at the top of the script, not three functions deep. If the check fails, the error points to the boundary where trust was assumed.

**Never trust env vars without fallbacks.** `${PTH_ROOT:-$(cd ...)}` — always have a fallback derivation, never assume the env is what you set it to.

**Log before you act.** Write the event before executing the side effect. If the script crashes mid-operation, the log tells you where it stopped.

**Every operation is auditable.** This is why the log system exists. If you cannot reconstruct what happened from `data/log/`, the operation was not properly instrumented.

---

## How these three work together

OSI tells you *where* to put code.
LDIDC tells you *what* each location is responsible for.
Adversarial tells you *how* to write the code once it's there.

A script that validates its arguments (Adversarial), calls only into its own layer or the one below (OSI), and lives in the directory that matches its responsibility (LDIDC) is a correct script by definition.

---

*These axioms are not aspirational. They are load-bearing. Violate them and the system becomes a tangle of hidden dependencies that breaks when moved, scaled, or handed to someone else.*
