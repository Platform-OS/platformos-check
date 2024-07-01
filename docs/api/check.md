# Check API

PlatformOS Check uses static analysis by parsing platformOS files into an Abstract Syntax Tree (AST), and then applying various checks to this structure.

An [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree), or Abstract Syntax Tree, is a tree representation of the abstract syntactic structure of a platformOS file. Each node in the tree corresponds to a part of the code.

The checks are implemented as Ruby classes with callback methods:

- `on_TYPE`: Runs before a node of the specific TYPE is visited.
- `after_TYPE`: Runs after a node of the specific TYPE has been visited.

Currently, PlatformOS Check supports three types of checks:

- [`LiquidCheck`](/docs/api/liquid_check.md)
- [`HtmlCheck`](/docs/api/html_check.md)
- [`YamlCheck`](/docs/api/yaml_check.md)
