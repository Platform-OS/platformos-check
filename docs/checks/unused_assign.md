# Prevent unused assigns (`UnusedAssign`)

This check exists to prevent bloat in themes by surfacing variable definitions that are not used.

## Check Details

This check is aimed at eliminating bloat in apps and highlight user errors.

:-1: Examples of **incorrect** code for this check:

```liquid
{% assign this_variable_is_not_used = 1 %}
```

```liquid
{% function this_variable_is_not_used = 'my_function' %}
```

:+1: Examples of **correct** code for this check:

```liquid
{% assign this_variable_is_used = 1 %}
{% if this_variable_is_used == 1 %}
  <span>Hello!</span>
{% endif %}
```

```liquid
{% function this_variable_is_used = 'my_function' %}
{% if this_variable_is_used == 1 %}
  <span>Hello!</span>
{% endif %}
```

```liquid
{% comment %}If you do not need to use the result of the function, start variable name with underscore{% endcomment %}
{% function _ignore_this_var = 'my_function' %}
```

## Check Options

The default configuration for this check is the following:

```yaml
UnusedAssign:
  enabled: true
```

## When Not To Use It

It's safe to disable this rule.

## Version

This check has been introduced in PlatformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/unused_assign.rb
[docsource]: /docs/checks/unused_assign.md
