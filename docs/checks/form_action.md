# Form Action (`FormAction`)

The form action defines the endpoint to which the browser will make a request after submitting the form.

As a general rule, you should use an absolute path, such as `action="/my/path"`, instead of a relative path like `action="my/path"`, to avoid errors.

## Check Details

This check ensures that the path correctly begins with a forward slash (`/`).

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

There should be no cases where disabling this rule is necessary.

## Version

This check has been introduced in PlatformOS Check 0.4.5.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/form_action.rb
[docsource]: /docs/checks/form_action.md
