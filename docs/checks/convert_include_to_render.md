# Discourage the use of `include` (`ConvertIncludeToRender`)

The `include` tag is [deprecated][deprecated]. This check exists to enforce the use of the `render` tag instead of `include`.

The `include` tag works similarly to the `render` tag, but it lets the code inside of the snippet to access and overwrite the variables within its parent theme file. The `include` tag has been deprecated because the way that it handles variables reduces performance and makes the code harder to both read and maintain.

## Check Details

This check is aimed at eliminating the use of `include` tags.

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

If you absolutely need to use variable as a partial name, it is not possible to use render tag, and this is the one exception for the include tag:

```liquid
{% liquid 
  # platformos-check-disable ConvertIncludeToRender
  include my_variable 
  # platformos-check-enable ConvertIncludeToRender
%}
```

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Deprecated Tags Reference][deprecated]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[deprecated]: https://documentation.platformos.com/api-reference/liquid/include
[codesource]: /lib/platformos_check/checks/convert_include_to_render.rb
[docsource]: /docs/checks/convert_include_to_render.md
