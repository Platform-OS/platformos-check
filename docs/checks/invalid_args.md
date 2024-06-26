# Prevent providing invalid arguments in `function`, `render` and `graphql` tags Liquid (`InvalidArgs`)

This check ensures that invalid arguments are not provided in `function`, `render`, and `graphql` tags in Liquid files.

## Check Details

The following examples contain code snippets that either fail or pass this check.

:-1: Examples of **incorrect** code for this check:

```liquid
{% comment %}app/graphql/my-query does not define invalid_argument{% endcomment %}
{% graphql res = 'my-query', invalid_argument: 10 %}
```

```liquid
{% function res = 'my-function', arg: 1, arg: 2 %}
```

```liquid
{% render res = 'my-partial', context: context %}
```

:+1: Examples of **correct** code for this check:

```liquid
{% comment %}app/graphql/my-query defines defined_argument{% endcomment %}
{% graphql res = 'my-query', defined_argument: 10 %}
```

## Check Options

The default configuration for this check is the following:

```yaml
InvalidArgs:
  enabled: true
```

| Parameter | Description |
| --- | --- |
| enabled | Whether the check is enabled. |
| severity | The [severity](https://documentation.platformos.com/developer-guide/platformos-check/platformos-check#check-severity) of the check. |

## When Not To Use It

It is not safe to disable this rule.

## Resources

- [platformOS GraphQL Reference](https://documentation.platformos.com/api-reference/graphql/glossary)
- [Rule source][codesource]
- [Documentation source][docsource]

[codesource]: /lib/platformos_check/checks/invalid_args.rb
[docsource]: /docs/checks/invalid_args.md