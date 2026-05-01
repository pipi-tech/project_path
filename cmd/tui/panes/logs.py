from textual.widgets import Static, Label, Log
from pathlib import Path

BASE     = Path.home() / "project/project_path"
LOG_BASE = BASE / "data/log"

FSF_COLORS = {
    "terminal": "#09F911",
    "registry": "#635688",
    "builder":  "#E35BD8",
    "config":   "#4156C5",
    "cli":      "#029D74",
    "dep":      "#E35BD8",
}

DOMAIN_ICONS = {
    "terminal": "⬢",
    "registry": "◈",
    "builder":  "⚙",
    "config":   "⚡",
    "dep":      "📦",
    "silent":   "👁",
}

def read_logs(limit=40):
    entries = []
    for domain in sorted(LOG_BASE.iterdir()):
        if not domain.is_dir():
            continue
        input_dir = domain / "input"
        if not input_dir.exists():
            continue
        for folder in sorted(input_dir.iterdir()):
            if not folder.is_dir():
                continue
            for f in sorted(folder.iterdir(), reverse=True)[:3]:
                try:
                    content = f.read_text().strip()
                    entries.append({
                        "domain":  domain.name,
                        "folder":  folder.name,
                        "ts":      f.stem,
                        "content": content[:80],
                    })
                except:
                    pass
    entries.sort(key=lambda x: x["ts"], reverse=True)
    return entries[:limit]


class LogPane(Static):
    def compose(self):
        yield Label("live logs", classes="pane-title")
        yield Log(id="log-output", auto_scroll=True)

    def on_mount(self):
        self.refresh_logs()
        self.set_interval(2.0, self.refresh_logs)

    def refresh_logs(self):
        log = self.query_one(Log)
        log.clear()
        for e in read_logs():
            color = FSF_COLORS.get(e["domain"], "#e0e0e0")
            icon  = DOMAIN_ICONS.get(e["folder"], DOMAIN_ICONS.get(e["domain"], "·"))
            log.write_line(
                f"{e['ts']}  {icon} [{e['domain']}:{e['folder']}]  {e['content']}"
            )
