# Form Action (`FormAction`)

The form action defines the endpoint to which the browser will make a request after submitting the form. As a general rule, you should use an absolute path, such as `action="/my/path"`, instead of a relative path like `action="my/path"`, to avoid errors. Using an absolute path ensures that the form submission always targets the correct endpoint, regardless of the current page's location. In contrast, a relative path could result in the form submitting to an unintended endpoint based on the current URL. 

This check ensures that the path correctly begins with a forward slash (`/`), which means it always refers to the root directory.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
<form action="dummy/create">
 ...
</form>
```

### &#x2713; Correct Code Example (Use this instead):

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

## Configuration Options

The default configuration for this check:

```yaml
FormAction:
  enabled: true
```

## Disabling This Check

Disabling this check is not recommended.

## Version

This check has been introduced in platformOS Check 0.4.5.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/form_action.rb
[docsource]: /docs/checks/form_action.md
