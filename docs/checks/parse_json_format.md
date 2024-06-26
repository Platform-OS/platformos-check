# Prevent Unformatted `parse_json` Tags (`ParseJsonFormat`)

_Version 1.9.0+_

This check ensures that the JSON in your `parse_json` tags is properly formatted (pretty) for better readability.

It helps facilitate auto-correction, allowing you to right-click and fix formatting issues easily.

## Examples

The following examples contain code snippets that either fail or pass this check.

:-1: Example of **incorrect** code for this check:

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

:+1: Example of **correct** code for this check:

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

## Check Options

The default configuration for this check is the following:

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
| severity | The [severity](https://documentation.platformos.com/developer-guide/platformos-check/platformos-check#check-severity) of the check. |
| start_level | The base indentation level. Set this to 1 if you prefer an indented `parse_json`. |
| indent | The character(s) used for indentation levels. |


## When Not To Use It

This check is safe to disable. You might choose to disable it if you do not care about the visual formatting of your `parse_json` tags.

## Resources

- [Rule source][codesource]
- [Documentation source][docsource]

[codesource]: /lib/platformos_check/checks/parse_json_format.rb
[docsource]: /docs/checks/parse_json_format.md
