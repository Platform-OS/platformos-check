# Form action (`FormAction`)

Form action defines the endpoint to which browser will make a request after submitting it.

As a general rule you should use relative path like `action="/my/path"` instead of for example `action="my/path"` to avoid errors.

## Check Details

This check is aimed at ensuring you have not forgotten to start the path with /.

:-1: Examples of **incorrect** code for this check:

```liquid
<form action="dummy/create">
 ...
</form>
```

:+1: Examples of **correct** code for this check:

```liquid
<form action="/dummy/create">
 ...
</form>
```

```liquid
<form action="{{ var }}">
 ...
</form>
```

```liquid
<form action="https://example.com/external">
 ...
</form>
```

## Check Options

The default configuration for this check is the following:

```yaml
FormAction:
  enabled: true
```

## When Not To Use It

There should be no cases where disabling this rule is needed.

## Version

This check has been introduced in PlatformOS Check 0.4.5.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/form_action.rb
[docsource]: /docs/checks/form_action.md
