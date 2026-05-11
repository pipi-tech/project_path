from textual.app import ComposeResult
from textual.screen import ModalScreen
from textual.widgets import Static, Label, Input
from textual.containers import Vertical, ScrollableContainer
from textual.reactive import reactive
from pathlib import Path
import subprocess, os

BASE     = Path.home() / "project/project_path"
REG_CONF = BASE / "data/registry.conf"
TYPE_REG = BASE / "cmd/config/type_registry.conf"
BUILDER  = BASE / "builder/src/build.sh"
TEMPLATE = BASE / "cmd/config/template/blank.toml"
INPUT    = BASE / "builder/input/test.toml"

PROJECT_PATHS = [
    str(Path.home() / "project"),
]

TARGETS = ["local", "venv", "conda", "docker", "podman", "lxd"]
ENVS    = ["dev", "test", "prod"]

def get_types():
    types = []
    if TYPE_REG.exists():
        for line in TYPE_REG.read_text().splitlines():
            if not line.startswith("#") and ":" in line:
                types.append(line.split(":")[0])
    types.append("> custom")
    return types

def get_registered_names():
    names = set()
    if REG_CONF.exists():
        for line in REG_CONF.read_text().splitlines():
            if not line.startswith("#") and line.strip():
                names.add(line.split(":")[0].lower())
    return names

def project_exists_on_disk(name, paths):
    for p in paths:
        if (Path(p) / name).exists():
            return True
    return False

STEPS = [
    {"key": "name",        "question": "project name",                     "type": "input",  "options": []},
    {"key": "save_path",   "question": "save location",                    "type": "select", "options": PROJECT_PATHS},
    {"key": "type",        "question": "project type",                     "type": "select", "options": []},
    {"key": "domain",      "question": "domain",                           "type": "input",  "options": []},
    {"key": "subtype",     "question": "subtype",                          "type": "input",  "options": []},
    {"key": "category",    "question": "category",                         "type": "input",  "options": []},
    {"key": "env",         "question": "runtime environment",              "type": "select", "options": ENVS},
    {"key": "target",      "question": "target (venv/conda/docker/etc)",   "type": "select", "options": TARGETS},
    {"key": "python",      "question": "python version (e.g. 3.12)",       "type": "input",  "options": []},
    {"key": "requires",    "question": "requires deps (empty to skip)",    "type": "multi",  "options": []},
    {"key": "dev",         "question": "dev deps (empty to skip)",         "type": "multi",  "options": []},
    {"key": "peer",        "question": "peer deps (empty to skip)",        "type": "multi",  "options": []},
    {"key": "confirm",     "question": "ready to build?",                  "type": "confirm","options": []},
]


class NewProjectWizard(ModalScreen):
    step       = reactive(0)
    answers    = reactive({})
    error_msg  = reactive("")
    sel_index  = reactive(0)
    multi_list = reactive([])

    def compose(self) -> ComposeResult:
        with Vertical(id="wizard-container"):
            yield Label("new project", id="wizard-title")
            yield Label("", id="wizard-progress")
            yield Label("", id="wizard-history")
            yield Label("", id="wizard-question")
            yield Label("", id="wizard-error")
            yield ScrollableContainer(id="wizard-options")
            yield Input(placeholder="", id="wizard-input")

    def on_mount(self):
        STEPS[2]["options"] = get_types()
        self.render_step()

    def render_step(self):
        s       = STEPS[self.step]
        total   = len(STEPS)
        current = self.step + 1

        self.query_one("#wizard-progress").update(
            f"[#444444]step {current}/{total}  {'█' * current}{'░' * (total - current)}[/]"
        )

        history = []
        for k, v in self.answers.items():
            if v:
                history.append(f"[#444444]{k}: [#029D74]{v}[/][/]")
        self.query_one("#wizard-history").update("\n".join(history[-5:]))
        self.query_one("#wizard-question").update(f"[#029D74]{s['question']}[/]")
        self.query_one("#wizard-error").update(
            f"[#E35BD8]{self.error_msg}[/]" if self.error_msg else ""
        )

        container = self.query_one("#wizard-options")
        container.remove_children()
        inp = self.query_one("#wizard-input")

        if s["type"] == "confirm":
            summary = "\n".join(f"[#4156C5]{k}[/]: [#e0e0e0]{v}[/]"
                                for k, v in self.answers.items() if v)
            container.mount(Label(summary))
            inp.display = False
            return

        if s["type"] in ("select",):
            inp.display = False
            for i, opt in enumerate(s["options"]):
                cls = "wizard-option-selected" if i == self.sel_index else "wizard-option"
                container.mount(Label(opt, classes=cls, id=f"opt-{i}"))
            return

        if s["type"] == "multi":
            inp.display = True
            inp.placeholder = "type dep, TAB to add, empty TAB to continue"
            if self.multi_list:
                container.mount(Label(
                    "  ".join(f"[#09F911]{d}[/]" for d in self.multi_list)
                ))
            return

        inp.display = True
        inp.placeholder = s["question"]
        inp.focus()

    def on_key(self, event):
        s = STEPS[self.step]

        if event.key == "escape":
            self.dismiss(None)
            return

        if event.key == "tab":
            self.error_msg = ""
            self._handle_tab(s)
            return

        if event.key == "shift+tab":
            self.error_msg = ""
            if self.step > 0:
                self.step -= 1
                self.sel_index = 0
                self.multi_list = []
                self.render_step()
            return

        if s["type"] == "select":
            if event.key == "up":
                self.sel_index = max(0, self.sel_index - 1)
                self.render_step()
            elif event.key == "down":
                self.sel_index = min(len(s["options"]) - 1, self.sel_index + 1)
                self.render_step()

    def _handle_tab(self, s):
        inp = self.query_one("#wizard-input")

        if s["type"] == "confirm":
            self._run_build()
            return

        if s["type"] == "select":
            val = s["options"][self.sel_index]
            if val == "> custom":
                self.query_one("#wizard-options").remove_children()
                inp.display = True
                inp.placeholder = "enter custom type"
                inp.focus()
                STEPS[self.step]["type"] = "input"
                return
            self._save_and_advance(s["key"], val)
            return

        if s["type"] == "multi":
            val = inp.value.strip()
            if val:
                self.multi_list = list(self.multi_list) + [val]
                inp.value = ""
                self.render_step()
            else:
                self._save_and_advance(s["key"], " ".join(self.multi_list))
                self.multi_list = []
            return

        val = inp.value.strip()

        if s["key"] == "name":
            if not val:
                self.error_msg = "name required"
                return
            val_clean = val.lower().replace(" ", "_")
            registered = get_registered_names()
            save_path  = self.answers.get("save_path", PROJECT_PATHS[0])
            if val_clean in registered:
                self.error_msg = f"'{val_clean}' already in registry"
                return
            if project_exists_on_disk(val_clean, [save_path]):
                self.error_msg = f"'{val_clean}' already exists on disk"
                return
            val = val_clean

        inp.value = ""
        self._save_and_advance(s["key"], val)

    def _save_and_advance(self, key, val):
        answers = dict(self.answers)
        answers[key] = val
        self.answers  = answers
        self.step     += 1
        self.sel_index = 0
        self.multi_list = []
        if self.step < len(STEPS):
            self.render_step()

    def _run_build(self):
        a = self.answers
        import shutil, tempfile

        shutil.copy(str(TEMPLATE), str(INPUT))

        def sed(key, val):
            os.system(
                f"sed -i 's|^{key}.*=.*|{key}        = \"{val}\"|' {INPUT}"
            )

        sed("name",     a.get("name",""))
        sed("domain",   a.get("domain",""))
        sed("subtype",  a.get("subtype",""))
        sed("category", a.get("category",""))
        sed("env",      a.get("env","dev"))
        sed("target",   a.get("target","local"))
        sed("python",   a.get("python",""))

        requires = a.get("requires","")
        dev      = a.get("dev","")
        peer     = a.get("peer","")

        def fmt_deps(d):
            if not d:
                return "[]"
            return "[" + ", ".join(f'"{x}"' for x in d.split()) + "]"

        os.system(f"sed -i 's|^requires.*=.*|requires    = {fmt_deps(requires)}|' {INPUT}")
        os.system(f"sed -i 's|^dev.*=.*|dev         = {fmt_deps(dev)}|' {INPUT}")
        os.system(f"sed -i 's|^peer.*=.*|peer        = {fmt_deps(peer)}|' {INPUT}")

        save_path = a.get("save_path", PROJECT_PATHS[0])
        os.environ["PROJECT_SAVE_PATH"] = save_path

        subprocess.Popen(
            ["bash", str(BUILDER), str(INPUT)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        self.dismiss(a.get("name"))
