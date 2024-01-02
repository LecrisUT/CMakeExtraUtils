project = "CMakeExtraUtils"
copyright = "2023, Cristian Le"
author = "Cristian Le"

extensions = [
    "myst_parser",
    "sphinx_design",
    "sphinx_togglebutton",
    "sphinxcontrib.moderncmakedomain",
    "sphinx.ext.intersphinx",
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
    "deflist",
]
myst_heading_anchors = 3

primary_domain = 'cmake'
highlight_language = 'cmake'


intersphinx_mapping = {
    "cmake": ("https://cmake.org/cmake/help/latest", None),
}
