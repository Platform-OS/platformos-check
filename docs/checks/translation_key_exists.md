# Translation Key Exists (`TranslationKeyExists`)

This check ensures that translation keys are defined in the default language, aiming to prevent missing translation errors.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
{{ 'undefined.key' | t }}
```

### &#x2713; Correct Code Example (Use this instead):

```liquid
{{ 'defined.key' | t }}

## Configuration Options

The default configuration for this check:

```yaml
TranslationKeyExists:
  enabled: true
```

## Disabling This Check

There should be no need to disable this rule. For keys set via the UI and not intended to be part of the codebase, use the appropriate configuration option in [app/config.yml](https://documentation.platformos.com/developer-guide/platformos-workflow/codebase/config).

## Version

This check has been introduced in platformOS Check 0.4.10.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/translation_key_exists.rb
[docsource]: /docs/checks/translation_key_exists.md
