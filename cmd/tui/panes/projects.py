from textual.widgets import Static, Label, DataTable
from textual.reactive import reactive
from pathlib import Path

BASE     = Path.home() / "project/project_path"
REG_CONF = BASE / "data/registry.conf"

def read_registry():
    projects = []
    if not REG_CONF.exists():
        return projects
    for line in REG_CONF.read_text().splitlines():
        if line.startswith("#") or not line.strip():
            continue
        parts = line.split(":")
        if len(parts) >= 5:
            projects.append({
                "name":        parts[0],
                "root":        parts[1].replace("~", str(Path.home())),
                "env":         parts[2],
                "environment": parts[3],
                "type":        parts[4],
            })
    return projects


class ProjPane(Static):
    def compose(self):
        yield Label("projects", classes="pane-title")
        yield DataTable(id="proj-table")

    def on_mount(self):
        table = self.query_one(DataTable)
        table.add_columns("name", "type", "env", "environment", "status")
        self.refresh_projects()

    def refresh_projects(self):
        table = self.query_one(DataTable)
        table.clear()
        for p in read_registry():
            root     = Path(p["root"])
            has_toml = (root / "project.toml").exists()
            status   = "● ok" if has_toml else "⚠ no toml"
            table.add_row(
                p["name"],
                p["type"],
                p["env"],
                p["environment"],
                status,
            )
