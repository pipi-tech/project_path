from textual.widgets import Static, Label
from textual.containers import Horizontal, ScrollableContainer
from textual.reactive import reactive
from pathlib import Path
from panes.projects import read_registry

SHOW_FIELDS = [
    "name","version","state","env","target",
    "node","project_id","active","hash"
]

def read_toml(root):
    toml_path = Path(root) / "project.toml"
    fields = {}
    if not toml_path.exists():
        return fields
    for line in toml_path.read_text().splitlines():
        if "=" in line and not line.strip().startswith("#") and not line.strip().startswith("["):
            k, _, v = line.partition("=")
            fields[k.strip()] = v.strip().strip('"')
    return fields


class TomlPane(Static):
    project_name = reactive("")

    def compose(self):
        yield Label("toml", classes="pane-title")
        yield ScrollableContainer(id="toml-fields")

    def watch_project_name(self, name):
        self.refresh_toml(name)

    def refresh_toml(self, name):
        container = self.query_one("#toml-fields")
        container.remove_children()
        if not name:
            return
        projects = {p["name"]: p for p in read_registry()}
        if name not in projects:
            return
        fields = read_toml(projects[name]["root"])
        for k in SHOW_FIELDS:
            if k in fields and fields[k]:
                container.mount(Horizontal(
                    Label(k,           classes="toml-key"),
                    Label(fields[k][:16], classes="toml-val"),
                ))
