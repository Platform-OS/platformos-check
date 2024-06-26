# Discourage Use of Parser-Blocking JavaScript (`ParserBlockingJavaScript`)

Using the `defer` or `async` attributes is extremely important on script tags. When neither of those attributes are used, a script tag will block the construction and rendering of the DOM until the script is _loaded_, _parsed_ and _executed_. This can create network congestion, interfere with resource priorities, and significantly delay page rendering.

JavaScript in platformOS apps should always be used to progressively _enhance_ the user experience. Therefore, parser-blocking script tags should never be used.

As a general rule:
- Use `defer` if the order of execution matters.
- Use `async` if the order of execution does not matter.
- When in doubt, using either will provide 80/20 of the benefits.

## Check Details

This check aims to eliminate parser-blocking JavaScript in your app.

:-1: Examples of **incorrect** code for this check:

```liquid
<!-- The script_tag filter outputs a parser-blocking script -->
{{ 'app-code.js' | asset_url | script_tag }}

<!-- jQuery is typically loaded synchronously because inline scripts depend on $, don't do that. -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
...
<button id="thing">Click me!</button>
<script>
  $('#thing').click(() => {
    alert('Oh. Hi Mark!');
  });
</script>
```

:+1: Examples of **correct** code for this check:

```liquid
<!-- Good. Using the asset_url filter + defer -->
<script src="{{ 'theme.js' | asset_url }}" defer></script>

<!-- Also good. Using the asset_url filter + async -->
<script src="{{ 'theme.js' | asset_url }}" async></script>

<!-- Better than synchronous jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js" defer></script>
...
<button id="thing">Click me!</button>
<script>
  // Because we're using `defer`, jQuery is guaranteed to
  // be loaded when DOMContentLoaded fires. This technique
  // could be used as a first step to refactor an old theme
  // that inline depends on jQuery.
  document.addEventListener('DOMContentLoaded', () => {
    $('#thing').click(() => {
      alert('Oh. Hi Mark!');
    });
  });
</script>

<!-- Even better. Web Native (no jQuery). -->
<button id="thing">Click Me</button>
<script>
  const button = document.getElementById('thing');
  button.addEventListener('click', () => {
    alert('Oh. Hi Mark!');
  });
</script>

<!-- Best -->
<script src="{{ 'theme.js' | asset_url }}" defer></script>
...
<button id="thing">Click Me</button>
```

## Check Options

The default configuration for this check is the following:

```yaml
ParserBlockingJavaScript:
  enabled: true
```

## When Not To Use It

This check should only be disabled with the `platformos-check-disable` comment if there is no better way to achieve the desired outcome than using a parser-blocking script.

It is generally discouraged to disable this rule.

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Lighthouse Render-Blocking Resources Audit][render-blocking]
- [Rule Source][codesource]
- [Documentation Source][docsource]

[render-blocking]: https://web.dev/render-blocking-resources/
[codesource]: /lib/platformos_check/checks/parser_blocking_javascript.rb
[docsource]: /docs/checks/parser_blocking_javascript.md
