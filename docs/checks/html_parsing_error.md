# Report HTML Parsing Errors (`HtmlParsingError`)

This check reports errors that prevent HTML from being properly parsed and analyzed by PlatformOS Check.

## Check Details

This check focuses on identifying HTML errors that prevent a file from being analyzed.

The HTML parser limits the number of attributes per element to 400, and the maximum depth of the Document Object Model (DOM) tree to 400 levels. If either of these limits is reached, parsing stops, and all HTML errors in the file are ignored.

:-1: Examples of **incorrect** code for this check:

```liquid
<img src="muffin.jpeg"
     data-attrbute-1=""
     data-attrbute-2=""
     ... up to
     data-attrbute-400="">
```

:+1: Examples of **correct** code for this check:

```liquid
<img src="muffin.jpeg">
```

## Check Options

The default configuration for this check is the following:

```yaml
HtmlParsingError:
  enabled: true
```

## When Not To Use It

This check may be disabled if identifying HTML errors is not a priority.

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/html_parsing_error.rb
[docsource]: /docs/checks/html_parsing_error.md
