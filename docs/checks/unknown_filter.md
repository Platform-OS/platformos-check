# Prevent Use of Unknown Filters (`UnknownFilter`)

This check prevents errors caused by using unknown filters in Liquid code and aims to eliminate the use of such filters.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
{{ x | some_unknown_filter }}
```

### &#x2713; Correct Code Example (Use this instead):

```liquid
{{ x | upcase }}
```

## Configuration Options

The default configuration for this check:

```yaml
UnknownFilter:
  enabled: true
```

## Disabling This Check

Disabling this check is not recommended, as it helps prevent user errors.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [Liquid Filter Reference](https://documentation.platformos.com/api-reference/liquid/filters)
- [platformOS Filter Reference](https://documentation.platformos.com/api-reference/liquid/platformos-filters)
- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/unknown_filter.rb
[docsource]: /docs/checks/unknown_filter.md
