# Discourage the Use of Large Template Files (`TemplateLength`)

This check aims to eliminate the use of large template files by encouraging a modular approach - using partials and functions to componentize your app instead.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Example (Avoid using this):

- Files that have more lines than the threshold

### &#x2713; Correct Example (Use this instead):

- Files that have less lines than the threshold

## Configuration Options

The default configuration for this check:

```yaml
TemplateLength:
  enabled: true
  max_length: 600
```

### `max_length`

The `max_length` (Default: `600`) option determines the maximum number of lines allowed inside a liquid file.

## Disabling This Check

This check is safe to disable if you do not prioritize template length management.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/template_length.rb
[docsource]: /docs/checks/template_length.md
