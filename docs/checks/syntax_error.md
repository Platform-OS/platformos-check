# Prevent Syntax Errors (`SyntaxError`)

This check helps inform the user of Liquid syntax errors early, aiming to eliminate syntax errors in Liquid code.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
{% include 'muffin'
{% assign foo = 1 }}
{% unknown %}
{% if collection | size > 0 %}
```

### &#x2713; Correct Code Example (Use this instead):

```liquid
{% include 'muffin' %}
{% assign foo  = 1 %}
{% if collection.size > 0 %}
```

## Configuration Options

The default configuration for this check:

```yaml
SyntaxError:
  enabled: true
```

## Disabling This Check

Disabling this check is not recommended.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/syntax_error.rb
[docsource]: /docs/checks/syntax_error.md
