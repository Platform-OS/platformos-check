# Prevent providing invalid GraphQL arguments from Liquid (`GraphqlArgs`)

This check exists to prevent providing invalid GraphQL arguments via `graphql` tag.

## Examples

The following examples contain code snippets that either fail or pass this check.

### &#x2717; Fail

```liquid
{% graphql res = 'my-query', invalid_argument: 10 %}
```

### &#x2713; Pass

```liquid
{% graphql res = 'my-query', defined_argument: 10 %}
```

## Options

The following example contains the default configuration for this check:

```yaml
GraphqlArgs:
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
