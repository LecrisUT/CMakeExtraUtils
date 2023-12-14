project = "CMakeExtraUtils"
copyright = "2023, Cristian Le"
author = "Cristian Le"

extensions = [
    "myst_parser",
    "sphinx_design",
    "sphinx_togglebutton",
    "sphinxcontrib.moderncmakedomain",
]

templates_path = []
exclude_patterns = [
    "build",
    "_build",
    "Thumbs.db",
    ".DS_Store",
    "README.md",
]
source_suffix = [".md"]

html_theme = "furo"

myst_enable_extensions = [
    "tasklist",
    "colon_fence",
]
