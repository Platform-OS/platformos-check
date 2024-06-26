# Form Authenticity Token (`FormAuthenticityToken`)

In platformOS, all POST, PATCH, PUT, and DELETE requests are protected from [CSRF Attacks][csrf-attack] by using an [authenticity_token][page-csrf]. This token verifies that the person submitting the form is the one who initially requested the web page.

It's important to add a hidden input field with the authenticity token in every form. The tag should look like this: 

```liquid
<input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">
```

If this token is missing from a form, the session will end and the user will be logged out automatically.

## Check Details

This check ensures that the `authenticity_token` is included in each form to keep the session safe and protect against CSRF.

:-1: Examples of **incorrect** code for this check:

```liquid
<form action="/dummy/create" method="post">
</form>
```

:+1: Examples of **correct** code for this check:

With token:
```liquid
<form action="/dummy/create" method="post">
  <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">
</form>
```

For GET request:
```liquid
<form action="/dummy/create">
</form>
```

For external request:
```liquid
<form action="https://example.com/dummy/create" method="post">
</form>
```

For parameterized request:
```liquid
<form action="{{ context.constants.MY_REQUEST_URL }}" method="post">
</form>
```

## Check Options

The default configuration for this check is the following:

```yaml
FormAuthenticityToken:
  enabled: true
```

## When Not To Use It

There should be no cases where disabling this rule is necessary.

## Version

This check has been introduced in PlatformOS Check 0.4.6.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]
- [platformOS Page documentation][page-csrf]
- [OWASP Cross Site Request Forgery][csrf-attack]

[codesource]: /lib/platformos_check/checks/form_authenticity_token.rb
[docsource]: /docs/checks/form_authenticity_token.md
[page-csrf]: https://documentation.platformos.com/developer-guide/pages/pages#post-put-patch-delete-methods-and-cross-site-request-forgery-attacks
[csrf-attack]: https://owasp.org/www-community/attacks/csrf