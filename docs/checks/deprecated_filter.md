# Discourage the use of deprecated filters (`DeprecatedFilter`)

This check discourages the use of [deprecated filters][deprecated].

## Check Details

This check is aimed at eliminating deprecated filters.

## Check Options

The default configuration for this check is the following:

```yaml
DeprecatedFilter:
  enabled: true
```

## Version

This check has been introduced in PlatformOS Check 0.1.0.

## Resources

- [Deprecated Filters Reference][deprecated]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[deprecated]: https://documentation.platformos.com/api-reference/liquid/platformos-filters
[codesource]: /lib/platformos_check/checks/deprecated_filter.rb
[docsource]: /docs/checks/deprecated_filter.md
