# Form authenticity token (`FormAuthenticityToken`)

In platformOS all POST/PATCH/PUT/DELETE requests are protected from [CSRF Attacks][csrf-attack] through [authenticity_token][page-csrf]
Form action defines the endpoint to which browser will make a request after submitting it.

As a general rule you should include hidden input `<input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">` in every form. Missing it will result in session invalidation and the logged in user will be automatically logged out.

## Check Details

This check is aimed at ensuring you have not forgotten to include authenticity_token in a form.

:-1: Examples of **incorrect** code for this check:

```liquid
<form action="dummy/create" method="post">
</form>
```

:+1: Examples of **correct** code for this check:

```liquid
<form action="/dummy/create" method="post">
  <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">
</form>
```

## Check Options

The default configuration for this check is the following:

```yaml
FormAuthenticityToken:
  enabled: true
```

## When Not To Use It

There should be no cases where disabling this rule is needed.

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

