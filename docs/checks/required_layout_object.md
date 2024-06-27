# Prevent Missing Required Objects in Layouts (`RequiredLayoutThemeObject`)

This check ensures that the `{{ content_for_layout }}` object is present in layouts, preventing rendering issues due to missing objects.

## Configuration Options

The default configuration for this check:

```yaml
RequiredLayoutObject:
  enabled: true
```

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [platformOS layout requirements][layout]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/required_layout_object.rb
[docsource]: /docs/checks/required_layout_object.md
[layout]: https://documentation.platformos.com/developer-guide/pages/layouts
