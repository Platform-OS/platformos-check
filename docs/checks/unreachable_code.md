# Unreachable code (`UnreachableCode`)

Unreachable code reports code that will never be reached, no matter what.

## Check Details

This check is aimed at ensuring you will not accidentally write code that will never be reached.

:-1: Examples of **incorrect** code for this check:

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

:+1: Examples of **correct** code for this check:

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

## Check Options

The default configuration for this check is the following:

```yaml
UnreachableCode:
  enabled: true
```

## When Not To Use It

There should be no cases where disabling this rule is needed.

## Version

This check has been introduced in PlatformOS Check 0.4.7.

## Resources

- [Rule Source][codesource]
- [Documentation Source][docsource]

[codesource]: /lib/platformos_check/checks/unreachable_code.rb
[docsource]: /docs/checks/unreachable_code.md
