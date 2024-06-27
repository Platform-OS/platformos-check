# Prevent Missing `platformos-check-enable` Comments (`MissingEnableComment`)

This check ensures that when `platformos-check-disable` is used within a theme file, a corresponding `platformos-check-enable` comment is included to re-enable the checks.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

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

### &#x2713; Correct Code Example (Use this instead):

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

This check has been introduced in platformOS Check 0.3.0.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/missing_enable_comment.rb
[docsource]: /docs/checks/missing_enable_comment.md
