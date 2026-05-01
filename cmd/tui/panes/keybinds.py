from textual.widgets import Static
from textual.reactive import reactive

FSF_GREEN  = "#09F911"
FSF_DIM    = "#444444"

KEYBINDS = {
    "root": [
        ("n","new"), ("r","refresh"), ("q","quit"),
        ("j","down"), ("k","up"), ("l","logs"), ("?","help"),
    ],
    "navigator": [
        ("enter","cd"), ("h","back"), ("j","down"), ("k","up"),
        ("space","preview"), ("esc","cancel"),
    ],
    "project": [
        ("enter","open"), ("d","deps"), ("f","fingerprint"),
        ("s","snap"), ("e","edit toml"), ("esc","back"),
    ],
    "logs": [
        ("c","clear"), ("f","filter"), ("t","tail"), ("esc","back"),
    ],
    "registry": [
        ("enter","show"), ("x","remove"), ("h","history"), ("esc","back"),
    ],
    "wizard": [
        ("TAB","next"), ("SHIFT+TAB","back"), ("↑↓","select"), ("ESC","cancel"),
    ],
}


class KeybindBar(Static):
    context = reactive("root")

    def render(self):
        binds = KEYBINDS.get(self.context, KEYBINDS["root"])
        parts = []
        for key, label in binds:
            parts.append(
                f"[bold {FSF_GREEN}]{key}[/] [{FSF_DIM}]{label}[/]"
            )
        return "  ".join(parts)
