# Encourage Use of `{% liquid ... %}` Tag for Consecutive Statements (`LiquidTag`)

This check recommends using the `{% liquid ... %}` tag when four or more consecutive Liquid tags (`{% ... %}`) are found.

## Check Details

he purpose of this check is to eliminate repetitive tag markers (`{%` and `%}`) in theme files for improved readability and maintainability.

:-1: Example of **incorrect** code for this check:

```liquid
{% if collection.image.size != 0 %}
{%   assign collection_image = collection.image %}
{% elsif collection.products.first.size != 0 and collection.products.first.media != empty %}
{%   assign collection_image = collection.products.first.featured_media.preview_image %}
{% else %}
{%   assign collection_image = nil %}
{% endif %}
```

:+1: Example of **correct** code for this check:

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

## Check Options

The default configuration for this check is the following:

```yaml
LiquidTag:
  enabled: true
  min_consecutive_statements: 5
```

### `min_consecutive_statements`

The `min_consecutive_statements` option (Default: `5`) determines the maximum (inclusive) number of consecutive statements required before the check recommends refactoring to use the `{% liquid ... %}` tag.

## When Not To Use It

It is generally safe to disable this rule if it does not align with your coding standards.

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [`{% liquid %}` Tag Reference][liquid]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[liquid]: https://documentation.platformos.com/api-reference/liquid/platformos-tags
[codesource]: /lib/platformos_check/checks/liquid_tag.rb
[docsource]: /docs/checks/liquid_tag.md
