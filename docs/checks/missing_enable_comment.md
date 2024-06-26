# Prevent Missing `platformos-check-enable` Comments (`MissingEnableComment`)

When `platformos-check-disable` is used within a theme file, a corresponding `platformos-check-enable` comment should be included to re-enable the checks.

## Check Details

This check ensures that `platformos-check-enable` comments are present when `platformos-check-disable` is used.

:-1: Example of **incorrect** code for this check:

```liquid
<!doctype html>
<html>
  <head>
    {% # platformos-check-disable ParserBlockingJavaScript %}
    <script src="https://cdnjs.com/jquery.min.js"></script>
  </head>
  <body>
    <!-- ... -->
  </body>
</html>
```

:+1: Example of **correct** code for this check:

```liquid
<!doctype html>
<html>
  <head>
    {% # platformos-check-disable ParserBlockingJavaScript %}
    <script src="https://cdnjs.com/jquery.min.js"></script>
    {% # platformos-check-enable ParserBlockingJavaScript %}
  </head>
  <body>
    <!-- ... -->
  </body>
</html>
```

## Version

This check has been introduced in PlatformOS Check 0.3.0.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/missing_enable_comment.rb
[docsource]: /docs/checks/missing_enable_comment.md
