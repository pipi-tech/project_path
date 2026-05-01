# 🛣️ project_path

> A comprehensive project scaffolding, organization, and documentation framework for managing development projects with integrated session tracking, dependency management, and automated doc generation.

## Overview

**project_path** is a shell-based framework that transforms how you manage projects. It provides:

- **Unified Project Registry** – Centralized tracking of all your projects
- **Smart Scaffolding** – Create new projects with guided setup
- **Dependency Management** – Multi-manager support (pip, npm, apt, cargo, conda)
- **Automatic Documentation** – Generate and maintain docs from your code
- **Session Tracking** – Trace activity and maintain project history
- **Environment Isolation** – Virtual environment management per project
- **Fingerprinting** – Detect configuration drift and ensure consistency

### 🧭 [Our Philosophy](docs/PHILOSOPHY.md)

Want to understand *why* project_path exists and what we believe about projects?  
Read our [Philosophy](docs/PHILOSOPHY.md) – a manifesto on how projects should live and breathe.

---

## Quick Start

### Installation
```bash
# Clone the repository
git clone https://github.com/pipi-tech/project_path.git
source project_path/scaffold.sh <YOUR_PROJECT_NAME> <YOUR_PROJECT_ROOT>
```

### Basic Commands
```bash
# Create a new project
new myproject

# Enter a project (activates venv)
proj myproject

# View all projects
proj

# Install dependencies from project.toml
deps install

# Generate project documentation
doc init myproject /path/to/project

# Run full build pipeline
build
```

## Core Features

### 📋 Project Registry
Manage all your projects from one place:
```bash
reg list              # Show all registered projects
reg show <name>       # View project details
reg history           # Full activity log
reg history <name>    # Project-specific history
reg remove <name>     # Unregister a project
```

### 🏗️ Builder & Fingerprinting
Ensure consistency and detect changes:
```bash
build                 # Run full build pipeline
fingerprint           # Generate project fingerprint
drift                 # Check for configuration drift
```

### 📦 Dependency Management
Flexible multi-package-manager support:
```bash
deps add <package>        # Add and install package
deps add-only <package>   # Add to TOML without installing
deps install              # Install from project.toml
deps compare              # Check installed vs declared
classify <manager>        # Classify dependencies by type
```

Supported managers:
- **pip** – Python packages
- **npm** – Node.js packages  
- **apt** – System packages
- **cargo** – Rust packages
- **conda** – Conda environments

### 📚 Documentation Worker
Automatically generate and maintain documentation:
```bash
doc init [name] [root]     # Initialize docs + open session
doc ref [name] [root]      # Regenerate reference from scripts
doc session open           # Start tracking session
doc session close          # End session + finalize logs
doc deps <dep> <mgr>       # Log dependency changes
doc log [name]             # View session logs
doc edit [name]            # Open latest session in editor
```

The documentation worker maintains:
- **arch/** – Architecture decisions and invariants (manual)
- **runbooks/** – Operations and debugging guides (manual)
- **ref/** – Auto-generated references from shell scripts
- **log/** – Session logs with annotations (auto + manual)

### 🎯 Configuration Management
```bash
domains set              # Configure logging domains for your project type
domains show             # View active log domains
domains types            # List available type categories
domains add-type <t>     # Register new project type
```

### 📝 Log Management
```bash
clearLogs               # Clear all log input folders
tailLogs                # Live view of all log streams
```

### 📋 Template System
Create project templates for consistent scaffolding:
```bash
tpl update              # Snapshot current structure as template
tpl stamp <target>      # Clone template to new location
tpl show                # View current template snapshot
tpl tree                # Live tree visualization
```

### 📊 Master References
Generate comprehensive reference files:
```bash
msrc                    # Write master source reference
mlog                    # Write master log reference
```

### 💻 Session Management
Track and audit all activities:
```bash
session show            # Current session hash + identity
session active          # List live and dead sessions
session clean           # Remove dead session files
session history         # View all past sessions
session find <hash>     # Trace all activity for a session
```

### 🖥️ TUI Dashboard
```bash
tui                     # Launch interactive dashboard
```

### 📦 Package Analysis
```bash
pkg_managers list              # Show all managers + counts
pkg_managers detect            # Auto-detect active managers
pkg_managers classify <mgr>    # Classify packages by category

aptlist manual                 # Manually installed packages
aptlist all                    # All installed packages
aptlist search <term>          # Search packages
aptlist all-managers           # Combined view (apt+snap+pip+cargo+flatpak)
```

## Project Structure

```
project_path/
├── builder/              # Build pipeline implementation
├── cmd/                  # Command implementations
│   └── config/
│       └── template/     # TOML templates
├── data/                 # Registry and configuration data
├── docs/                 # Documentation worker
│   ├── arch/
│   ├── runbooks/
│   ├── ref/
│   └── log/
├── engines/              # Modular engine implementations
├── functions/            # Reusable shell functions
├── project.toml          # Framework configuration
├── scaffold.sh           # Installation script
└── v1Goal.txt           # v1.0 roadmap
```

## Configuration

### project.toml
Each project has a `project.toml` with sections for:

**Identity**
```toml
[project]
name        = "myproject"
version     = "0.1.0"
description = "Project description"
state       = "active"
author      = "Your Name"
```

**Type Classification**
```toml
[type]
domain      = "backend"
subtype     = "api"
category    = "service"
```

**Runtime**
```toml
[runtime]
env         = "dev"
target      = "local"
venv        = ".venv"
```

**Managers**
```toml
[managers]
active      = "pip npm"
pip         = "true"
npm         = "true"
```

**Dependencies**
```toml
[dependencies]
python      = "3.12.3"
requires    = ["requests", "click"]
dev         = ["pytest", "black"]
```

**Fingerprint**
```toml
[fingerprint]
hash            = "..."
generated_at    = "2026-05-01_12-00-00"
generated_by    = "username"
```

**Registry**
```toml
[registry]
project_id  = "..."
node        = "hostname"
locked_by   = ""
lock_time   = ""
```

## Roadmap – v1.0

### Must Have
- [ ] ✅ Session hashing (reliable session tracking)
- [ ] ✅ Complete clearLogs implementation
- [ ] ✅ Container registry integration
- [ ] ✅ Remote project entry capability

### Nice to Have
- [ ] State engine (IDLE/ACTIVE/BUILD management)
- [ ] Comprehensive test suite
- [ ] Snapshot/recovery system

## Use Cases

### Multi-Project Management
Keep dozens of projects organized and discoverable with the registry system.

### Consistent Environments
Ensure every team member has identical dependencies and configurations.

### Audit Trail
Complete session history and logging for compliance and debugging.

### Documentation
Auto-generate reference docs from your scripts and maintain changelog automatically.

### CI/CD Integration
Use fingerprinting and drift detection in your pipelines for consistency checks.

## Requirements

- **Bash 4.0+** – Shell scripting
- **Python 3.8+** – For Python-based tooling
- **Node.js/npm** – Optional, if managing JavaScript projects
- **Rust/cargo** – Optional, if managing Rust projects

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source. See LICENSE file for details.

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing documentation in `docs/`
- Review command reference: `cat cmd_list`

## Status

**Version:** 0.1.0  
**State:** Active (Prototype)  
**Last Updated:** 2026-05-01

---

**Made with ❤️ by pipi-tech**
