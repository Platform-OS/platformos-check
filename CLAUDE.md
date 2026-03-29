# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

platformOS Check is a linter and language server (LSP) for platformOS applications. It analyzes Liquid templates, JSON, YAML, and GraphQL files to enforce best practices, identify performance issues, and catch errors. Written in Ruby 3.2+.

## Common Commands

```bash
# Run all tests (runs against both InMemory and FileSystem storage)
bundle exec rake test

# Run tests with specific storage (faster for development)
bundle exec rake tests:in_memory
bundle exec rake tests:file_system

# Run a single test file
bundle exec ruby -Itest test/checks/unused_assign_test.rb

# Run linter
bundle exec rubocop

# Run CLI on a platformOS app
bin/platformos-check /path/to/app

# Create a new check (generates check, test, and docs files)
bundle exec rake "new_check[MyCheckName]"

# Update platformOS Liquid documentation
bundle exec rake download_theme_liquid_docs
```

## Architecture

### Entry Points
- `bin/platformos-check` - CLI tool
- `bin/platformos-check-language-server` - LSP server for IDE integration

### Core Components

**Analyzer** (`lib/platformos_check/analyzer.rb`): Central orchestrator that runs checks. Manages check lifecycle: `analyze_platformos_app()` → `analyze_files()` → `finish()`.

**App** (`lib/platformos_check/app.rb`): Represents a platformOS application as a collection of typed files (LiquidFile, YamlFile, GraphqlFile, etc.). Uses regex patterns to categorize files into pages, partials, forms, layouts, etc.

**Check System** (`lib/platformos_check/check.rb`): Base class for all checks. Checks inherit from `LiquidCheck`, `YamlCheck`, or `HtmlCheck` and implement visitor methods like `on_document`, `on_assign`, `on_variable_lookup`, `on_end`.

**Storage Layer**: Abstract interface with two implementations:
- `FileSystemStorage` - Reads from disk (production)
- `InMemoryStorage` - For language server and tests

**Language Server** (`lib/platformos_check/language_server/`): LSP implementation with completion providers, hover providers, code action providers, and diagnostics engine.

### Visitor Pattern
Checks use a visitor pattern for AST traversal. The `LiquidVisitor` walks Liquid AST and calls check methods (`on_assign`, `on_graphql`, etc.).

### Reporting Offenses
```ruby
add_offense(message, node:) do |corrector|
  corrector.replace(node.range, "fixed code")
end
```

## Creating a New Check

1. Run `bundle exec rake "new_check[CheckName]"`
2. Implement the check in `lib/platformos_check/checks/check_name.rb`
3. Add configuration to `config/default.yml`
4. Write tests in `test/checks/check_name_test.rb`

## Debugging

```bash
# Enable debug mode (disables timeouts, enables --profile flag)
export PLATFORMOS_CHECK_DEBUG=true

# Language server logging
export PLATFORMOS_CHECK_DEBUG_LOG_FILE=/tmp/platformos-check-debug.log
```

## Configuration

Project configuration is in `.platformos-check.yml`. Default check settings are in `config/default.yml`.

Checks can be disabled in code:
```liquid
{% # platformos-check-disable CheckName %}
...
{% # platformos-check-enable CheckName %}
```
