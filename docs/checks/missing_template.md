# Prevent Missing Templates (`MissingTemplate`)

This check ensures that resources specified with the `render` tag, `function` tag, and the deprecated `include` tag actually exist.

## Check Details

This check aims to prevent Liquid rendering errors caused by referencing non-existent templates.

:-1: Example of **incorrect** code for this check:

```liquid
{% render 'partial-that-does-not-exist' %}
```

:+1: Example of **correct** code for this check:

```liquid
{% render 'partial-that-exists' %}
```

## Check Options

The default configuration for this check is the following:

```yaml
MissingTemplate:
  enabled: true
  ignore_missing: []
```

### `ignore_missing`

Specify a list of patterns for missing template files to ignore.

- The `ignore` option ignores all occurrences of `MissingTemplate` according to the file in which they appear.
- The `ignore_missing` option ignores all occurrences of `MissingTemplate` based on the target template, the template being rendered.

For example:

```yaml
MissingTemplate:
  ignore_missing:
  - icon-*
```

This configuration ignores offenses on `{% render 'icon-missing' %}` across all app files.

```yaml
MissingTemplate:
  ignore:
  - modules/private-module/index.liquid
```

This configuration ignores all `MissingTemplate` offenses in `modules/private-module/index.liquid`, regardless of the file being rendered.

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/missing_template.rb
[docsource]: /docs/checks/missing_template.md
