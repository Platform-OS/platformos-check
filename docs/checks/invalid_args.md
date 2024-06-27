# Prevent providing invalid arguments in `function`, `render` and `graphql` tags Liquid (`InvalidArgs`)

This check ensures that invalid arguments are not provided in `function`, `render`, and `graphql` tags in Liquid files.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

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

### &#x2713; Correct Code Example (Use this instead):

```liquid
{% comment %}app/graphql/my-query defines defined_argument{% endcomment %}
{% graphql res = 'my-query', defined_argument: 10 %}
```

## Configuration Options

The default configuration for this check:

```yaml
InvalidArgs:
  enabled: true
```

| Parameter | Description |
| --- | --- |
| enabled | Whether the check is enabled. |
| severity | The [severity](https://documentation.platformos.com/developer-guide/platformos-check/platformos-check#check-severity) of the check. |

## Disabling This Check

Disabling this check is not recommended.

## Resources

- [platformOS GraphQL Reference](https://documentation.platformos.com/api-reference/graphql/glossary)
- [Rule source][codesource]
- [Documentation source][docsource]

[codesource]: /lib/platformos_check/checks/invalid_args.rb
[docsource]: /docs/checks/invalid_args.md