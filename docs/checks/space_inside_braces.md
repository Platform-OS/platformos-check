# Ensure consistent spacing inside Liquid tags and variables (`SpaceInsideBraces`)

Warns against inconsistent spacing inside liquid tags and variables.

## Check Details

This check is aimed at eliminating ugly Liquid:

:-1: Examples of **incorrect** code for this check:

```liquid
<!-- Around braces -->
{% assign x = 1%}
{{ x}}
{{x }}

<!-- After commas and semicolons -->
{% background source_name: 'type',  object, key:value %}
{% endbackground %}

<!-- Arround filter pipelines -->
{{ url  | asset_url | strip }}
{% assign my_upcase_string = "Hello world"| upcase %}

<!-- Arround symbol operators -->
{%- if target  == product and product.price_varies -%}
{%- if product.featured_media.width >=165 -%}
```

:+1: Examples of **correct** code for this check:

```liquid
{% assign x = 1 %}
{{ x }}
{% background source_name: 'type', object, key: value, key2: value %}
{% endbackground %}
{{ "ignore:stuff,  indeed" }}
{% render 'product-card',
  product_card_product: product_recommendation,
  show_vendor: section.settings.show_vendor,
  media_size: section.settings.product_recommendations_image_ratio,
  center_align_text: section.settings.center_align_text
%}
{{ url | asset_url | strip }}
{% assign my_upcase_string = "Hello world" | upcase %}
{%- if target == product and product.price_varies -%}
{%- if product.featured_media.width >= 165 -%}
```

## Check Options

The default configuration for this check is the following:

```yaml
SpaceInsideBraces:
  enabled: true
```

## Auto-correction

This check can automatically trim or add spaces around `{{ ... }}`.

```liquid
{{ x}}
{{x}}
{{  x  }}
```

Can all be auto-corrected with the `--auto-correct` option to:

```liquid
{{ x }}
```

## When Not To Use It

If you don't care about the look of your code.

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/space_inside_braces.rb
[docsource]: /docs/checks/space_inside_braces.md
