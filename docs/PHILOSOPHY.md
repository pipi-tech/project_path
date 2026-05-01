# 🧭 project_path Philosophy

This is not just a tool. It's a way of thinking about how projects should live and breathe.

---

## 1. Projects Are Journeys, Not Folders

Most tools treat a project as a directory structure. We treat it as a **lifecycle**.

A project has:
- **Creation** – how it begins
- **Setup** – dependencies, environments
- **Development** – building, testing, changing
- **Documentation** – capturing decisions
- **Sessions** – tracking what happened
- **Builds** – ensuring consistency
- **Drift Detection** – catching changes
- **Knowledge Capture** – learning from experience

This is a **narrative**, not a structure. We help you tell that story.

---

## 2. The Terminal Should Be Your Companion

Your CLI isn't a command runner. It's an assistant.

It should:
- **Remember** what you did (sessions, history)
- **Help you understand** what changed (drift detection)
- **Keep your docs alive** (automated documentation)
- **Keep your dependencies honest** (tracking, comparison)
- **Guide you** when you're lost (clear commands, helpful feedback)

A good tool doesn't make you work harder.  
It makes you work smarter.

---

## 3. Reproducibility Is a Superpower

We're obsessed with consistency:

- **Fingerprints** – detect what changed
- **Drift Detection** – catch configuration skew
- **Dependency Snapshots** – lock what works
- **Environment Isolation** – consistent venvs
- **Session Tracking** – know the history

This philosophy is inspired by Nix and similar reproducible systems, but we keep it human-centered and practical.

**The Goal:**
> If you run this project a year from now, it will still work.

That's freedom. That's confidence.

---

## 4. Documentation Should Write Itself

Documentation that depends on discipline will rot.

We believe:
- **Auto-generate what you can** – references from source code
- **Automate what you must** – session logs, changelogs
- **Make manual docs easy** – architecture decisions, runbooks
- **Keep it alive** – integrate docs into your workflow

Documentation isn't a separate task. It's part of the project.

---

## 5. Tools Should Grow With You

We don't believe in rigid frameworks.

project_path starts simple:
```bash
new myproject
proj myproject
deps install
build
```

But it grows with you:
- **Modular engines** – add capabilities
- **Template system** – scale your patterns
- **Session tracking** – audit what matters
- **Custom types** – categorize your projects
- **Multi-manager support** – work with any tech stack

Good tools adapt to you. You shouldn't have to adapt to them.

---

## 6. Everything Should Be Transparent

We believe in visibility:

- **Project state** – what's happening now?
- **Dependencies** – what's installed and why?
- **Sessions** – who did what and when?
- **Builds** – what changed between runs?
- **History** – how did we get here?

Hidden state breeds bugs. Transparency builds trust.

---

## The Vision

project_path is building a world where:

✅ Projects are organized and traceable  
✅ Developers feel confident in their environments  
✅ Documentation stays fresh and useful  
✅ Dependencies are understood and tracked  
✅ History is preserved and searchable  
✅ Tools adapt to you, not the reverse  

We're not there yet. But we're building toward it.

---

**Made with intention by pipi-tech**
