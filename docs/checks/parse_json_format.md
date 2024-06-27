# Prevent Unformatted `parse_json` Tags (`ParseJsonFormat`)

This check ensures that the JSON in your `parse_json` tags is properly formatted (pretty) for better readability. It facilitates auto-correction, allowing you to right-click and fix formatting issues easily.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

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

### &#x2713; Correct Code Example (Use this instead):

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

## Configuration Options

The default configuration for this check:

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


## Disabling This Check

This check is safe to disable if you do not care about the visual formatting of your `parse_json` tags.

## Version

This check has been introduced in platformOS Check 1.9.0.

## Resources

- [Rule source][codesource]
- [Documentation source][docsource]

[codesource]: /lib/platformos_check/checks/parse_json_format.rb
[docsource]: /docs/checks/parse_json_format.md
