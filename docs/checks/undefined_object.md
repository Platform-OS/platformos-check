# Prevent undefined object errors (`UndefinedObject`)

This check prevents errors by making sure that no undefined variables are being used

## Check Details

This check is aimed at eliminating undefined object errors. Additionally it reports any missing or unused attributes in render, function and background tags.

:-1: Examples of **incorrect** code for this check:

```liquid
{% if greeting == "Hello" %}
  Hello
{% endif %}
```

:+1: Examples of **correct** code for this check:

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



## Check Options

The default configuration for this check is the following:

```yaml
UndefinedObject:
  enabled: true
```

## When Not To Use It

It is discouraged to disable this rule.

## Version

This check has been introduced in Theme Check 0.1.0.

## Resources

- [platformOS Context](https://documentation.platformos.com/developer-guide/variables/context-variable#displaying-the-context-object)
- [platformOS Object Reference](https://documentation.platformos.com/api-reference/liquid/objects)
- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/undefined_object.rb
[docsource]: /docs/checks/undefined_object.md
