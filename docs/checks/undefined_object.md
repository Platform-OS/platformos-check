# Prevent Undefined Object Errors (`UndefinedObject`)

This check ensures that no undefined variables are used, preventing errors in your Liquid code. It aims to eliminate undefined object errors and additionally reports any missing or unused attributes in `render`, `function`, and `background` tags.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
{% if greeting == "Hello" %}
  Hello
{% endif %}
```

### &#x2713; Correct Code Example (Use this instead):

```liquid
{% assign greetings = "Hello" %}
{% if greetings == "Hello" %}
  Hello
{% endif %}
```

```liquid
{% function res = 'my_function' %}
```

```liquid
{% liquid
  # my_function body
  assign my_arg = my_arg | default: nil
  return my_arg
%}
```

## Configuration Options

The default configuration for this check:

```yaml
UndefinedObject:
  enabled: true
```

## Disabling This Check

Disabling this check is not recommended.

## Version

This check has been introduced in Theme Check 0.1.0.

## Resources

- [platformOS Context](https://documentation.platformos.com/developer-guide/variables/context-variable#displaying-the-context-object)
- [platformOS Object Reference](https://documentation.platformos.com/api-reference/liquid/objects)
- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/undefined_object.rb
[docsource]: /docs/checks/undefined_object.md
