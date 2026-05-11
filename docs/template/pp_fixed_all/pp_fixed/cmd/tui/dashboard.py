import sys
sys.path.insert(0, "/home/maven/project/project_path/cmd/tui")

from textual.app import App, ComposeResult
from textual.widgets import Static, Label, DataTable
from textual.containers import Horizontal, Vertical
from textual.reactive import reactive
from textual.binding import Binding
from pathlib import Path

from styles.fsf import CSS, FSF
from panes.nav import NavPane
from panes.projects import ProjPane
from panes.logs import LogPane
from panes.toml_view import TomlPane
from panes.snaps import SnapPane
from panes.keybinds import KeybindBar
from modals.new_project import NewProjectWizard


class Dashboard(App):
    CSS = CSS

    BINDINGS = [
        Binding("q",         "quit",        "quit"),
        Binding("n",         "new_project", "new"),
        Binding("r",         "refresh",     "refresh"),
        Binding("j",         "nav_down",    "down"),
        Binding("k",         "nav_up",      "up"),
        Binding("h",         "nav_back",    "back"),
        Binding("enter",     "select",      "select"),
        Binding("esc",       "back",        "back"),
        Binding("l",         "focus_logs",  "logs"),
    ]

    context = reactive("root")

    def compose(self) -> ComposeResult:
        yield Static(
            f"[bold {FSF['green']}]project_path[/]  "
            f"[{FSF['dim']}]maven@pop-os[/]  "
            f"[{FSF['teal']}]09 F9 11 02 9D 74 E3 5B D8 41 56 C5 63 56 88 C0[/]",
            id="topbar"
        )
        with Horizontal(id="main"):
            yield NavPane(id="nav-pane")
            with Vertical(id="center-pane"):
                yield ProjPane(id="proj-pane")
                yield LogPane(id="log-pane")
            with Vertical(id="right-pane"):
                yield TomlPane(id="toml-pane")
                yield SnapPane(id="snap-pane")
        yield KeybindBar(id="keybind-bar")

    def on_mount(self):
        self.query_one(KeybindBar).context = "root"

    def watch_context(self, ctx):
        self.query_one(KeybindBar).context = ctx

    def on_data_table_row_highlighted(self, event):
        try:
            table = self.query_one("#proj-table", DataTable)
            row   = table.get_row_at(event.cursor_row)
            name  = str(row[0])
            self.query_one(TomlPane).project_name  = name
            self.query_one(SnapPane).project_name  = name
            self.context = "project"
        except:
            pass

    def action_nav_down(self):
        self.query_one(NavPane).action_nav_down()
        self.context = "navigator"

    def action_nav_up(self):
        self.query_one(NavPane).action_nav_up()
        self.context = "navigator"

    def action_nav_back(self):
        self.query_one(NavPane).action_nav_back()

    def action_select(self):
        self.query_one(NavPane).action_nav_enter()

    def action_back(self):
        self.context = "root"

    def action_focus_logs(self):
        self.context = "logs"

    def action_refresh(self):
        self.query_one(ProjPane).refresh_projects()
        self.query_one(LogPane).refresh_logs()

    def action_new_project(self):
        self.context = "wizard"
        self.push_screen(NewProjectWizard(), callback=self._on_new_project_done)

    def _on_new_project_done(self, name):
        self.context = "root"
        if name:
            self.notify(f"building: {name}", title="new project")
            self.set_timer(3.0, self.action_refresh)


if __name__ == "__main__":
    app = Dashboard()
    app.run()
