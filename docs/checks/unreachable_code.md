# Unreachable Code (`UnreachableCode`)

This check detects and ensures that you do not accidentally write code that will never be executed because it is unreachable.

## Examples

The following examples show code snippets that either fail or pass this check:

### &#x2717; Incorrect Code Example (Avoid using this):

```liquid
  assign x = "hello"
  break
  log x
```

```liquid
  if x
    log x
  else
    break
    log "Stop"
  endif
```

### &#x2713; Correct Code Example (Use this instead):

```liquid
  assign x = "hello"
  log x
  break
```

```liquid
  if x
    log x
  else
    log "Stop"
    break
  endif
```

## Configuration Options

The default configuration for this check:

```yaml
UnreachableCode:
  enabled: true
```

## Disabling This Check

Disabling this check is not recommended.

## Version

This check has been introduced in platformOS Check 0.4.7.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/unreachable_code.rb
[docsource]: /docs/checks/unreachable_code.md
