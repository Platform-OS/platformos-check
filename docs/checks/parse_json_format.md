# Prevent unformatted parse_json tags (`ParseJsonFormat`)

_Version 1.9.0+_

This check exists to ensure the JSON in your parses is pretty.

It exists as a facilitator for its auto-correction. This way you can right-click fix the problem.

## Examples

The following examples contain code snippets that either fail or pass this check.

### &#x2717; Fail

```liquid
{% parse_json my_json %}
{
  "locales": {
"en": {
  "title": "Welcome", "product": "Product"
},
          "fr": { "title": "Bienvenue", "product": "Produit" }
  }
}
{% endparse_json %}
```

### &#x2713; Pass

```liquid
{% parse_json my_json %}
{
  "locales": {
    "en": {
      "title": "Welcome",
      "product": "Product"
    },
    "fr": {
      "title": "Bienvenue",
      "product": "Produit"
    }
  }
}
{% endparse_json %}
```

## Options

The following example contains the default configuration for this check:

```yaml
ParseJsonFormat:
  enabled: true
  severity: style
  start_level: 0
  indent: '  '
```

| Parameter | Description |
| --- | --- |
| enabled | Whether the check is enabled. |
| severity | The [severity](https://shopify.dev/themes/tools/platformos-check/configuration#check-severity) of the check. |
| start_level | The indentation level. If you prefer an indented parse_json, set this to 1. |
| indent | The character(s) used for indentation levels. |

## Disabling this check

 This check is safe to disable. You might want to disable this check if you do not care about the visual appearance of your parse_json tags.

## Resources

- [Rule source][codesource]
- [Documentation source][docsource]

[codesource]: /lib/platformos_check/checks/parse_json_format.rb
[docsource]: /docs/checks/parse_json_format.md
