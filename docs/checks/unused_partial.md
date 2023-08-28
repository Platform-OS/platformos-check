# Remove unused partials in app (`UnusedPartial`)

This check warns the user about partials that are not used (Could not find a `render` or `function` tag that uses that partial)

## Check Details

This check is aimed at eliminating unused partials.

## Check Options

The default configuration for this check is the following:

```yaml
UnusedPartial:
  enabled: true
```

## When Not To Use It

It's safe to disable this rule.

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/unused_partial.rb
[docsource]: /docs/checks/unused_partial.md
