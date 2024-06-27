# Report usage of `include` tag inside `render` (`IncludeInRender`)

A runtime error occurs when an `include` tag is used inside a `render` tag. This check aims to eliminate and report these occurrences.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

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

### &#x2713; Correct Code Example (Use this instead):

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

## Configuration Options

The default configuration for this check:

```yaml
IncludeInRender:
  enabled: true
```

## Disabling This Check

Disabling this check is not recommended.

## Version

This check has been introduced in platformOS Check 0.4.9.

## Resources

- [Deprecated Tags Reference][deprecated]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[deprecated]: https://documentation.platformos.com/api-reference/liquid/include
[codesource]: /lib/platformos_check/checks/convert_include_to_render.rb
[docsource]: /docs/checks/convert_include_to_render.md
