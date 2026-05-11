from textual.widgets import Static, Label
from textual.containers import ScrollableContainer
from textual.reactive import reactive
from pathlib import Path
import uuid

def nav_tree(path, depth=0, max_depth=2):
    items = []
    try:
        p = Path(path)
        for child in sorted(p.iterdir()):
            if child.name.startswith("."):
                continue
            is_dir = child.is_dir()
            items.append({
                "path": str(child),
                "name": child.name,
                "depth": depth,
                "is_dir": is_dir,
            })
            if is_dir and depth < max_depth:
                items.extend(nav_tree(child, depth + 1, max_depth))
    except PermissionError:
        pass
    return items


class NavPane(Static):
    nav_index = reactive(0)
    nav_path  = reactive(str(Path.home() / "project"))
    _items    = []

    def compose(self):
        yield Label("navigator", classes="pane-title")
        yield ScrollableContainer(id="nav-list")

    def on_mount(self):
        self.refresh_nav()

    def refresh_nav(self):
        container = self.query_one("#nav-list")
        container.remove_children()
        items = nav_tree(self.nav_path)
        self._items = items
        for i, item in enumerate(items):
            indent = "  " * item["depth"]
            icon   = "▶ " if item["is_dir"] else "  "
            label  = f"{indent}{icon}{item['name']}"
            cls    = "nav-item dir" if item["is_dir"] else "nav-item"
            uid    = str(uuid.uuid4()).replace("-", "")[:8]
            extra  = " nav-selected" if i == self.nav_index else ""
            container.mount(Label(label, classes=cls + extra, id=f"nav-{uid}"))

    def action_nav_down(self):
        self._items = nav_tree(self.nav_path)
        self.nav_index = min(self.nav_index + 1, len(self._items) - 1)
        self.refresh_nav()

    def action_nav_up(self):
        self.nav_index = max(self.nav_index - 1, 0)
        self.refresh_nav()

    def action_nav_enter(self):
        if self._items and self.nav_index < len(self._items):
            item = self._items[self.nav_index]
            if item["is_dir"]:
                self.nav_path  = item["path"]
                self.nav_index = 0
                self.refresh_nav()

    def action_nav_back(self):
        parent = str(Path(self.nav_path).parent)
        if parent != self.nav_path:
            self.nav_path  = parent
            self.nav_index = 0
            self.refresh_nav()

    def current_item(self):
        if self._items and self.nav_index < len(self._items):
            return self._items[self.nav_index]
        return None
