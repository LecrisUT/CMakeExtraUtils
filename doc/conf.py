project = 'CMakeExtraUtils'
copyright = '2023, Cristian Le'
author = 'Cristian Le'

extensions = [
    "myst_parser",
    "sphinx_design",
    "sphinx_togglebutton",
    "breathe",
]

templates_path = []
exclude_patterns = [
    'build',
    '_build',
    'Thumbs.db',
    '.DS_Store',
    "README.md",
]
source_suffix = [".md"]


html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']

myst_enable_extensions = [
    "tasklist",
    "colon_fence",
]
