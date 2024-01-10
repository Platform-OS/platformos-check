# Reports usage of `include` tag inside `render` (`IncludeInRender`)

Runtime error is used when `include` tag is used inside `render` tag.

## Check Details

This check is aimed at eliminating the use of `include` tags `render` tag.

:-1: Examples of **incorrect** code for this check:

```liquid
{% liquid
  # app/views/pages/index.liquid
  render 'foo'
%}
```liquid
{% liquid
  # app/views/partials/foo.liquid
  include 'bar'
%}
```

:+1: Examples of **correct** code for this check:

```liquid
{% liquid
  # app/views/pages/index.liquid
  render 'foo'
%}
```liquid
{% liquid
  # app/views/partials/foo.liquid
  render 'bar'
%}
```

## Check Options

The default configuration for this check is the following:

```yaml
IncludeInRender:
  enabled: true
```

## When Not To Use It

It is discouraged to disable this rule.

## Version

This check has been introduced in PlatformOS Check 0.4.9.

## Resources

- [Deprecated Tags Reference][deprecated]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[deprecated]: https://documentation.platformos.com/api-reference/liquid/include
[codesource]: /lib/platformos_check/checks/convert_include_to_render.rb
[docsource]: /docs/checks/convert_include_to_render.md
