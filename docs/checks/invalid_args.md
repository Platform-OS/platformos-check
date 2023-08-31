# Prevent providing invalid arguments in function, render and graphql tags Liquid (`InvalidArgs`)

This check exists to prevent providing invalid arguments via `function`, `render` and `graphql` tags.

## Examples

The following examples contain code snippets that either fail or pass this check.

### &#x2717; Fail

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

### &#x2713; Pass

```liquid
{% comment %}app/graphql/my-query defines defined_argument{% endcomment %}
{% graphql res = 'my-query', defined_argument: 10 %}
```

## Options

The following example contains the default configuration for this check:

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

[codesource]: /lib/platformos_check/checks/graphql_args.rb
[docsource]: /docs/checks/graphql_args.md
