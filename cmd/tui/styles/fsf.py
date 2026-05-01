FSF = {
    "green":   "#09F911",
    "teal":    "#029D74",
    "magenta": "#E35BD8",
    "blue":    "#4156C5",
    "purple":  "#635688",
    "bg":      "#0d0d0d",
    "bg2":     "#161616",
    "bg3":     "#1e1e1e",
    "dim":     "#444444",
    "text":    "#e0e0e0",
}

CSS = f"""
Screen {{
    background: {FSF['bg']};
    color: {FSF['text']};
    layout: vertical;
}}
#topbar {{
    height: 1;
    background: {FSF['bg3']};
    color: {FSF['purple']};
    padding: 0 2;
}}
#main {{
    layout: horizontal;
    height: 1fr;
}}
#nav-pane {{
    width: 24;
    background: {FSF['bg2']};
    border-right: solid {FSF['purple']};
    padding: 1;
}}
#center-pane {{
    width: 1fr;
    layout: vertical;
}}
#proj-pane {{
    height: 1fr;
    background: {FSF['bg2']};
    border-bottom: solid {FSF['dim']};
    padding: 1;
}}
#log-pane {{
    height: 1fr;
    background: {FSF['bg']};
    padding: 1;
}}
#right-pane {{
    width: 28;
    background: {FSF['bg2']};
    border-left: solid {FSF['purple']};
    layout: vertical;
}}
#toml-pane {{
    height: 1fr;
    padding: 1;
    border-bottom: solid {FSF['dim']};
}}
#snap-pane {{
    height: 1fr;
    padding: 1;
}}
#keybind-bar {{
    height: 1;
    background: {FSF['bg3']};
    layout: horizontal;
    padding: 0 1;
}}
.pane-title {{
    color: {FSF['teal']};
    text-style: bold;
    margin-bottom: 1;
}}
.nav-item {{
    color: {FSF['text']};
    padding: 0 1;
}}
.nav-item.dir {{
    color: {FSF['teal']};
}}
.nav-selected {{
    background: {FSF['purple']};
    color: {FSF['text']};
    text-style: bold;
}}
.proj-name {{ color: {FSF['text']}; width: 16; }}
.proj-type {{ color: {FSF['green']}; width: 12; }}
.proj-env  {{ color: {FSF['dim']}; width: 12; }}
.proj-status-ok   {{ color: {FSF['teal']}; }}
.proj-status-warn {{ color: {FSF['magenta']}; }}
.log-terminal {{ color: {FSF['green']}; }}
.log-registry {{ color: {FSF['purple']}; }}
.log-builder  {{ color: {FSF['magenta']}; }}
.toml-key {{ color: {FSF['blue']}; width: 14; }}
.toml-val {{ color: {FSF['text']}; }}
.snap-hot  {{ color: {FSF['magenta']}; }}
.snap-warm {{ color: {FSF['teal']}; }}
.snap-cold {{ color: {FSF['purple']}; }}
DataTable {{
    background: {FSF['bg2']};
    color: {FSF['text']};
}}
DataTable > .datatable--header {{
    background: {FSF['bg3']};
    color: {FSF['teal']};
    text-style: bold;
}}
DataTable > .datatable--cursor {{
    background: {FSF['purple']};
    color: {FSF['text']};
}}
ModalScreen {{
    background: rgba(0,0,0,0.85);
    align: center middle;
}}
#wizard-container {{
    width: 60;
    height: auto;
    background: {FSF['bg3']};
    border: solid {FSF['purple']};
    padding: 2;
}}
#wizard-title {{
    color: {FSF['green']};
    text-style: bold;
    margin-bottom: 1;
}}
#wizard-progress {{
    color: {FSF['dim']};
    margin-bottom: 1;
}}
#wizard-question {{
    color: {FSF['teal']};
    margin-bottom: 1;
}}
#wizard-input {{
    margin-bottom: 1;
}}
#wizard-error {{
    color: {FSF['magenta']};
    margin-bottom: 1;
}}
#wizard-history {{
    color: {FSF['dim']};
    margin-bottom: 1;
}}
.wizard-option {{
    padding: 0 1;
    color: {FSF['text']};
}}
.wizard-option-selected {{
    background: {FSF['purple']};
    color: {FSF['text']};
    text-style: bold;
}}
"""
