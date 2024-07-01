# Discourage the Use of `include` (`ConvertIncludeToRender`)

The purpose of this check is to discourage the use of `include` tags and ensure the use of `render` tags instead. The `include` tag is now considered [deprecated][deprecated], and it is recommended to use the `render` tag to help maintain the efficiency and readability of your code.


## Why Use `render` instead of `include`

While the `include` tag functions similarly to the `render` tag by inserting snippets of code into files, there's a key difference: `include` allows the code within the snippet to access and overwrite the variables in its parent platformOS file. This can make your website slower and your code harder to read and maintain. That’s why it’s recommended to use the simpler `render` tag instead.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
{% include 'snippet' %}
```

### &#x2713; Correct Code Example (Use this instead):

```liquid
{% render 'snippet' %}
```

## Configuration Options

The default configuration for this check:

```yaml
ConvertIncludeToRender:
  enabled: true
```

## Disabling This Check - When Not To Use It

### Using Variable Partial Names

There is an exception to using the `render` tag: if you need to use a variable as a partial name. In such cases, the `include` tag remains necessary because the `render` tag does not support variable partial names.
Here's how you can use the include tag for this specific scenario:

```liquid
{% liquid 
  # platformos-check-disable ConvertIncludeToRender
  include my_variable 
  # platformos-check-enable ConvertIncludeToRender
%}
```

This example shows how to temporarily disable the check when you need to use `include` specifically for variable partial names.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [Deprecated Tags Reference][deprecated]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[deprecated]: https://documentation.platformos.com/api-reference/liquid/include
[codesource]: /lib/platformos_check/checks/convert_include_to_render.rb
[docsource]: /docs/checks/convert_include_to_render.md