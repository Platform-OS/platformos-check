# Report usage of `include` tag inside `render` (`IncludeInRender`)

A runtime error occurs when an `include` tag is used inside a `render` tag. This check identifies and reports these occurrences.

## Check Details

This check aims to eliminate the use of `include` tags within `render` tags.

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

It is not safe to disable this rule.

## Version

This check has been introduced in PlatformOS Check 0.4.9.

## Resources

- [Deprecated Tags Reference][deprecated]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[deprecated]: https://documentation.platformos.com/api-reference/liquid/include
[codesource]: /lib/platformos_check/checks/convert_include_to_render.rb
[docsource]: /docs/checks/convert_include_to_render.md
