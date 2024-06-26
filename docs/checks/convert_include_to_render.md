# Discourage the Use of `include` (`ConvertIncludeToRender`)

The `include` tag is now considered [deprecated][deprecated], and it is recommended to use the `render` tag instead. This check enforces using the `render` tag instead of `include` to help maintain the efficiency and readability of your code.

## Difference between `include` and  `render`

While the `include` tag functions similarly to the `render` tag by inserting snippets of code into files, there's a key difference: `include` allows the code within the snippet to access and overwrite the variables in its parent theme file. This can make your website slower and your code harder to read and maintain. That’s why it’s recommended to use the simpler `render` tag instead.

## Check Details

The purpose of this check is to discourage the use of `include` tags.

:-1: Examples of **incorrect** code for this check:

```liquid
{% include 'snippet' %}
```

:+1: Examples of **correct** code for this check:

```liquid
{% render 'snippet' %}
```

## Check Options

The default configuration for this check is the following:

```yaml
ConvertIncludeToRender:
  enabled: true
```

## When Not To Use It

### Exception: Variable Partial Names

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

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Deprecated Tags Reference][deprecated]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[deprecated]: https://documentation.platformos.com/api-reference/liquid/include
[codesource]: /lib/platformos_check/checks/convert_include_to_render.rb
[docsource]: /docs/checks/convert_include_to_render.md