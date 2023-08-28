# Prevent missing required objects in theme.liquid (`RequiredLayoutThemeObject`)

## Check Details

This check prevents missing `{{ content_for_layout }}` objects in layouts.

## Check Options

The default configuration for this check is the following:

```yaml
RequiredLayoutObject:
  enabled: true
```

## Version

This check has been introduced in Theme Check 0.1.0.

## Resources

- [platformOS layout requirements][layout]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/required_layout_object.rb
[docsource]: /docs/checks/required_layout_object.md
[layout]: https://documentation.platformos.com/developer-guide/pages/layouts
