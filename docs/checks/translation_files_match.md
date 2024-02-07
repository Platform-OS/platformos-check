# Translation Files Match (`TranslationFilesMatch`)

Checks if translation files for different language have the same keys.

## Check Details

This check is aimed at avoiding inconsistences between translation files to avoid errors hard to spot and make maintenance easier.

:-1: Examples of **incorrect** code for this check:

```yaml
# app/translations/en/item.yml
  en:
    app:
      item:
        title: "Item"
        description: "Description"

# app/translations/de/item.yml
  en:
    app:
      item:
        description: "Beschreibung"
```

Missing "title" in de/item.yml

:+1: Examples of **correct** code for this check:

```yaml
# app/translations/en/item.yml
  en:
    app:
      item:
        title: "Item"
        description: "Description"

# app/translations/de/item.yml
  en:
    app:
      item:
        title: "Artikel"
        description: "Beschreibung"
```

## Check Options

The default configuration for this check is the following:

```yaml
TranslationFilesMatch:
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

[codesource]: /lib/platformos_check/checks/translation_files_match.rb
[docsource]: /docs/checks/translation_files_match.md
