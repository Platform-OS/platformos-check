# Translation Files Match (`TranslationFilesMatch`)

This check ensures that translation files for different languages have the same keys, aiming to avoid inconsistencies, making it easier to spot errors and maintain the code.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

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

### &#x2713; Correct Code Example (Use this instead):

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

## Configuration Options

The default configuration for this check:

```yaml
TranslationFilesMatch:
  enabled: true
```

## Disabling This Check

There should be no need to disable this rule. For keys set via the UI and not intended to be part of the codebase, use the appropriate configuration option in [app/config.yml](https://documentation.platformos.com/developer-guide/platformos-workflow/codebase/config).

## Version

This check has been introduced in platformOS Check 0.4.10.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/translation_files_match.rb
[docsource]: /docs/checks/translation_files_match.md
