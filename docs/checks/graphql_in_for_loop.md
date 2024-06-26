# GraphQL in For Loop (`GraphqlInForLoop`)

This check is designed to prevent performance issues that can arise when GraphQL queries or mutations are executed within a `for loop`. Invoking GraphQL queries/mutations inside for loops can lead to performance issues such as increased database load, higher latency, and inefficient use of network resources. This issue becomes even more noticeable with large datasets or as the number of entities processed grows.

Invoking a GraphQL query within a `for loop` might also be a sign of a so called N+1 problem. The N+1 pattern often arises when dealing with relationships between entities. In an attempt to retrieve related data, developers may inadvertently end up executing a large number of queries, resulting in a significant performance overhead.

To address this problem, developers can use techniques like eager loading, which involves fetching the related data in a single query instead of issuing separate queries for each entity. This helps reduce the number of database round-trips and improves overall system performance. In platformOS, the N+1 issue is commonly handled by [using related_records][related_records].

## Check Details

This check identifies GraphQL queries invoked within a `for loop`, helping prevent performance problems before they start.

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

Ideally, there should be no need to disable this rule, as platformOS likely offers alternative solutions to handle scenarios without using a GraphQL query or mutation inside a for loop.

## Version

This check has been introduced in PlatformOS Check 0.4.9.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]
- [platformOS - loading related records][related_records]

[codesource]: /lib/platformos_check/checks/graphql_in_for_loop.rb
[docsource]: /docs/checks/graphql_in_for_loop.md
[related_records]: https://documentation.platformos.com/developer-guide/records/loading-related-records
