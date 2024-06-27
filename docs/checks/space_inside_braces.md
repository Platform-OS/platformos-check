# Ensure Consistent Spacing Inside Liquid Tags and Variables (`SpaceInsideBraces`)

This check warns against and aims to eliminate inconsistent spacing inside Liquid tags and variables, ensuring cleaner and more readable Liquid code.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

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

### &#x2713; Correct Code Example (Use this instead):

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

## Configuration Options

The default configuration for this check:

```yaml
SpaceInsideBraces:
  enabled: true
```

## Auto-correction

This check can automatically correct spacing around `{{ ... }}`. For example:

```liquid
{{ x}}
{{x}}
{{  x  }}
```

Can all be auto-corrected with the `--auto-correct` option to:

```liquid
{{ x }}
```

## Disabling This Check

This check is safe to disable if you do not prioritize the visual consistency of your code.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/space_inside_braces.rb
[docsource]: /docs/checks/space_inside_braces.md
