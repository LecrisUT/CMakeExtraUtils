# About the documentation

## Building the documentation

To build the documentation, first install the necessary documentation python packages. These are available in `docs`
optional dependencies:

```console
$ pip install .[docs]
```

Then, to build the documentations simply run:

```console
$ sphinx-build . ./build
```

For more intensive documentation editing I recommend using `sphinx-autobuild` which serves the generated documentation
(default `http://127.0.0.1:8000`) and automatically rebuilds it whenever you make changes.

```console
$ sphinx-autobuild . ./build
```

## Documentation notes

We heavily reuse the documentation already found in the source markdown files like the installation instructions in
[`Readme.md`](../README.md#Installation). See an example in [install.md](install.md). Please do not use
sphinx/myst_parser specific directives for these included files. Use the files in this `doc` folder to insert the
sphinx/myst_parser specific directives.

The main cmake module documentations is found in the [cmake folder](../cmake). Make sure that there is a skeleton
markdown files in [`cmake_modules`](cmake_modules) folder, e.g. [`DynamicVersion.md`](cmake_modules/DynamicVersion.md).

Other personal standards applied:

- Use markdown file format only
- Use [colon-fence](https://myst-parser.readthedocs.io/en/v1.0.0/syntax/optional.html#code-fences-using-colons) `:::` instead of triple-tick ```` ``` ````
- Use [yaml](https://myst-parser.readthedocs.io/en/v1.0.0/configuration.html#frontmatter-local-configuration) for directive configurations
