# Report HTML Parsing Errors (`HtmlParsingError`)

This check reports errors that prevent HTML from being properly parsed and analyzed by PlatformOS Check. It focuses on identifying HTML errors that hinder file analysis.

The HTML parser limits the number of attributes per element to 400 and the maximum depth of the Document Object Model (DOM) tree to 400 levels. If either of these limits is reached, parsing stops, and all HTML errors in the file are ignored.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
<img src="muffin.jpeg"
     data-attrbute-1=""
     data-attrbute-2=""
     ... up to
     data-attrbute-400="">
```

### &#x2713; Correct Code Example (Use this instead):

```liquid
<img src="muffin.jpeg">
```

## Configuration Options

The default configuration for this check:

```yaml
HtmlParsingError:
  enabled: true
```

## Disabling This Check

This check is safe to disable if identifying HTML errors is not a priority.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/html_parsing_error.rb
[docsource]: /docs/checks/html_parsing_error.md
