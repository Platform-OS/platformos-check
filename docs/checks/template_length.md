# Discourage the Use of Large Template Files (`TemplateLength`)

This check discourages the use of large template files. Instead, use partials and functions to componentize your app.

## Check Details

This check aims to eliminate large template files by encouraging a modular approach.

:-1: Examples of **incorrect** code for this check:

- Files that have more lines than the threshold

:+1: Examples of **correct** code for this check:

- Files that have less lines than the threshold

## Check Options

The default configuration for this check is the following:

```yaml
TemplateLength:
  enabled: true
  max_length: 600
```

### `max_length`

The `max_length` (Default: `200`) option determines the maximum number of lines allowed inside a liquid file.

## When Not To Use It

This rule can be safely disabled if you do not prioritize template length management.

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/template_length.rb
[docsource]: /docs/checks/template_length.md
