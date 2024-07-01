# Encourage Use of `{% liquid ... %}` Tag for Consecutive Statements (`LiquidTag`)

This check recommends using the `{% liquid ... %}` tag when four or more consecutive Liquid tags (`{% ... %}`) are found. The purpose of this check is to eliminate repetitive tag markers (`{%` and `%}`) in your platformOS application files for improved readability and maintainability.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
{% if collection.image.size != 0 %}
{%   assign collection_image = collection.image %}
{% elsif collection.products.first.size != 0 and collection.products.first.media != empty %}
{%   assign collection_image = collection.products.first.featured_media.preview_image %}
{% else %}
{%   assign collection_image = nil %}
{% endif %}
```

### &#x2713; Correct Code Example (Use this instead):

```liquid
{%- liquid
  if collection.image.size != 0
    assign collection_image = collection.image
  elsif collection.products.first.size != 0 and collection.products.first.media != empty
    assign collection_image = collection.products.first.featured_media.preview_image
  else
    assign collection_image = nil
  endif
-%}
```

## Configuration Options

The default configuration for this check:

```yaml
LiquidTag:
  enabled: true
  min_consecutive_statements: 5
```

### `min_consecutive_statements`

The `min_consecutive_statements` option (Default: `5`) determines the maximum (inclusive) number of consecutive statements required before the check recommends refactoring to use the `{% liquid ... %}` tag.

## Disabling This Check

This check is safe to disable if it does not align with your coding standards.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [`{% liquid %}` Tag Reference][liquid]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[liquid]: https://documentation.platformos.com/api-reference/liquid/platformos-tags
[codesource]: /lib/platformos_check/checks/liquid_tag.rb
[docsource]: /docs/checks/liquid_tag.md
