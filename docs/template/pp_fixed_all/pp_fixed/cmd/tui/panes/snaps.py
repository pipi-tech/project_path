from textual.widgets import Static, Label
from textual.containers import ScrollableContainer
from textual.reactive import reactive
from pathlib import Path
from panes.projects import read_registry, BASE

SNAP_BASE = BASE / "data/log/config/snap"


class SnapPane(Static):
    project_name = reactive("")

    def compose(self):
        yield Label("snaps", classes="pane-title")
        yield ScrollableContainer(id="snap-list")
        yield Label("keybinds", classes="pane-title")
        yield Label("TAB → confirm  SHIFT+TAB → back", id="kb-hint")

    def watch_project_name(self, name):
        self.refresh_snaps(name)

    def refresh_snaps(self, name):
        container = self.query_one("#snap-list")
        container.remove_children()
        for tier in ["hot", "warm", "cold"]:
            tier_path = SNAP_BASE / tier
            cls = f"snap-{tier}"
            if tier_path.exists() and name:
                matches = [s for s in tier_path.iterdir() if name in s.name]
                if matches:
                    for s in matches[:2]:
                        container.mount(Label(f"● {tier}  {s.name[:18]}", classes=cls))
                    continue
            container.mount(Label(f"● {tier}  none", classes=cls))
