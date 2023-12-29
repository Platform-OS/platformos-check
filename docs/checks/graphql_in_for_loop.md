# GraphQL in for loop (`GraphqlInForLoop`)

This check is aimed towards identifying performance problems before they arise. Invoking GraphQL queries/mutations inside the `for loop` can lead to performance issues such as increased database load, higher latency, and inefficient use of network resources. It is particularly problematic when dealing with large datasets or when the number of entities grows.

Invoking a GraphQL query within a `for loop` might also be a sign of a so called N+1 problem. The N+1 pattern often arises when dealing with relationships between entities. In an attempt to retrieve related data, developers may inadvertently end up executing a large number of queries, resulting in a significant performance overhead.

To address this problem, developers can use techniques like eager loading, which involves fetching the related data in a single query instead of issuing separate queries for each entity. This helps reduce the number of database round-trips and improves overall system performance. In platformOS the most common technique to fix the N+1 issue is by [using related_records][relalted_records].

## Check Details

This check is aimed towards identifying GraphQL queries invoked within a for loop.

:-1: Examples of **incorrect** code for this check:

```liquid
{% assign arr = 'a,b,c' | split: ','}
{% for el in arr %}
  {% graphql g = 'my/graphql', el: el %}
  {% print el %}
{% endfor %}

```

:+1: Examples of **correct** code for this check:

```liquid
{% assign arr = 'a,b,c' | split: ','}
{% graphql g = 'my/graphql', arr: arr %}
```

## Check Options

The default configuration for this check is the following:

```yaml
GraphqlInForLoop:
  enabled: true
```

## When Not To Use It

In the perfect world, there should be no cases where disabling this rule is needed - platformOS most likely already has a way to solve a problem without using GraphQL query / mutation in the for loop.

## Version

This check has been introduced in PlatformOS Check 0.4.9.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]
- [platformOS - loading related records][related_records]

[codesource]: /lib/platformos_check/checks/graphql_in_for_loop.rb
[docsource]: /docs/checks/graphql_in_for_loop.md
[related_records]: https://documentation.platformos.com/developer-guide/records/loading-related-records
