# Enforce valid YAML (`ValidYaml`)

This check exists to prevent invalid Yaml files in app.

## Check Details

This check is aimed at eliminating errors in YAML files.

:-1: Examples of **incorrect** code for this check:

```yaml
---
hello: world
invalid
```

:+1: Examples of **correct** code for this check:

```yaml
---
hello: world
invalid:
```

## Check Options

The default configuration for this check is the following:

```yaml
Validyaml:
  enabled: true
```

## When Not To Use It

It is not safe to disable this rule.

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/valid_yaml.rb
[docsource]: /docs/checks/valid_yaml.md
