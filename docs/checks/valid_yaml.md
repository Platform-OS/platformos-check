# Enforce Valid YAML (`ValidYaml`)

This check ensures that YAML files in the app are valid and aims to eliminate errors in these files.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```yaml
---
hello: world
invalid
```

### &#x2713; Correct Code Example (Use this instead):

```yaml
---
hello: world
invalid:
```

## Configuration Options

The default configuration for this check:

```yaml
Validyaml:
  enabled: true
```

## Disabling This Check

Disabling this check is not recommended.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/valid_yaml.rb
[docsource]: /docs/checks/valid_yaml.md
