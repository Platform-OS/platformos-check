# Translation Key Exists (`TranslationKeyExists`)

Checks if translation key is defined in the default language

## Check Details

This check is aimed at avoiding missing translation error.

:-1: Examples of **incorrect** code for this check:

```liquid
{{ 'undefined.key' | t }}
```

:+1: Examples of **correct** code for this check:

```liquid
{{ 'defined.key' | t }}

## Check Options

The default configuration for this check is the following:

```yaml
TranslationKeyExists:
  enabled: true
```

## When Not To Use It

There should be no cases where disabling this rule is needed. For keys that are set via UI, and hence should not be part of the codebase,
use proper configuration option in [app/config.yml](https://documentation.platformos.com/developer-guide/platformos-workflow/codebase/config)

## Version

This check has been introduced in PlatformOS Check 0.4.10.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/translation_key_exists.rb
[docsource]: /docs/checks/translation_key_exists.md
