# Prevent Unused Assigns (`UnusedAssign`)

This check helps prevent bloat in themes by identifying variable definitions that are not used, aiming to eliminate unnecessary code in apps and highlight user errors.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
{% assign this_variable_is_not_used = 1 %}
```

```liquid
{% function this_variable_is_not_used = 'my_function' %}
```

### &#x2713; Correct Code Example (Use this instead):

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

## Configuration Options

The default configuration for this check:

```yaml
UnusedAssign:
  enabled: true
```

## Disabling This Check

This check is safe to disable if you do not prioritize eliminating unused variables.

## Version

This check has been introduced in platformOS Check 0.0.1.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/unused_assign.rb
[docsource]: /docs/checks/unused_assign.md
