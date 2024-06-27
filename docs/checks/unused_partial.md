# Remove Unused Partials in App (`UnusedPartial`)

This check warns the user about partials that are not used, specifically when no `render` or `function` tag references the partial, and aims to eliminate these unused partials from your app.

## Configuration Options

The default configuration for this check:

```yaml
UnusedPartial:
  enabled: true
```

## Disabling This Check

This check is safe to disable if managing unused partials is not a priority.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/unused_partial.rb
[docsource]: /docs/checks/unused_partial.md
