# Prevent missing directories (`RequiredDirectories`)

This check exists to warn platformOS developers about missing directories in their structure.

## Check Options

The default configuration for this check is the following:

```yaml
RequiredDirectories:
  enabled: true
```

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [platformOS Directory Structure](https://documentation.platformos.com/developer-guide/platformos-workflow/codebase#required-directory-structure)
- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/required_directories.rb
[docsource]: /docs/checks/required_directories.md
