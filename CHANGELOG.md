v0.4.14 / 2024-10-11
==================

  * Add support for module overwrite

v0.4.13 / 2024-10-07
==================

  * Lock liquid version
  * Fix rubocop warnings

v0.4.12 / 2024-04-13
==================

  * Suggest filters with input_type 'untyped'

v0.4.11 / 2024-03-11
==================

  * Do not throw parse error for empty GraphQL file
  * enable MissingTemplate Check in single file mode
  * report if file is blank in MissingTemplate check
  * add support for background tag in MissingTemplate check


v0.4.10 / 2024-02-19
==================

  * Add documentLink for translations (both for `| t` and `| l` filters)
  * Add TranslationKeyExists, TranslationFilesMatch offenses to warn about issues with missing translation or inconsistency between multiple language translation files

v0.4.9 / 2024-01-10
==================

  * Skip FormAuthenticityToken check for GET forms
  * Skip FormAuthenticityToken for action which is not relative path
  * Fix FormAction to not report offenses on valid scenarios
  * UnusedAssign will not automatically remove assign if it might change the business logic (which is a scenario when filters modifying objects are used)
  * UnusedAssign will automatically rename result of background tag if variable not used
  * Fix reporting UndefinedObject's missing argument offenses when the same partial is used multiple times (previously offenses where displayed only for the last render)
  * Add autocorrector for UndefinedObject's missing argument error (explicitly provide null)
  * Add autocorrector for ImgLazyLoading
  * ConvertIncludeToRender will not report offense as autocorrect
  * Improve inline GraphQL syntax check to raise error if result variable not provided
  * Add autocorrector for UndefinedObject (Unused Argument offense) (FIXME: for N unused arguments in the same line it needs to be invoked N times)
  * Add autocorrector for InvalidArgs - remove duplicates arguments
  * Do not report ConvertIncludeToRender offenses for valid use cases (using `break` and using variable as a template name)
  * Add IncludeInRender check
  * Improve autocorrector for UndefinedObject's missing argument error - if variable is defined, it will be passed instead of hardcoding null
  * Re-enable autocorrector for ConvertIncludeToRender
  * Make UndefinedObject more clever - it will report undefined object if variable is used before declaration

v0.4.8 / 2023-12-20
==================

  * Add GraphqlInForLoop check

v0.4.7 / 2023-12-27
==================

  * Add UnreachableCode check

v0.4.6 / 2023-12-19
==================

  * Add FormAuthenticityToken check

v0.4.5 / 2023-12-19
==================

  * Add FormAction check

v0.4.4 / 2023-12-04
==================

  * Fix displaying description for filters

v0.4.3 / 2023-09-25
==================

  * Do not remove variable if it's later used via hash_assign

v0.4.2 / 2023-09-21
==================

  * Do not crash when creating a new directory

v0.4.1 / 2023-09-19
==================

  * Complete variables assigned by function and graphql tags
  * Global objects accessible only in api calls
  * Parse graphql partial name

v0.4.0 / 2023-09-17
==================

  * Add unused attributes messages in render/function/background tags invocations

v0.3.3 / 2023-09-16
==================

  * Fix issue with inline graphql tag old syntax

v0.3.2 / 2023-09-15
==================

  * Allow nil prefix, which should be equivalent of ""

v0.3.1 / 2023-09-15
==================

  * Complete global objects only for certain types

v0.3.0 / 2023-09-15
==================

  * Support for theme_render_rc tag

v0.2.2 / 2023-09-15
==================

  * Do not crash when directory is copied to partials path

v0.2.1 / 2023-09-14
==================

  * Single file should be default mode for LSP now
  * Make all checks work in single file mode - greatly enhance performance

v0.2.0 / 2023-09-13
==================

  * Completion and hover for tags
  * Fix completion from the middle of the partial

v0.1.0 / 2023-09-13
==================

  * Better documentation for filters
  * Display documentation for filter aliases (l, t, etc.)
  * Support fuzzy autocomplete for render, include, graphql, background and function tags

v0.0.3 / 2023-09-11
==================

  * Fix GraphQL dependency issue
  * Support background tag in UndefinedObject check

v0.0.2 / 2023-09-09
==================

  * Add documentLink support for pOS tags for easy navigation, aka ctrl + click to quickly access file invoked by render, include, graphql, background and include_form tags
  * Treat Form as liquid file and check it

v0.0.1 / 2023-08-19
==================

  * Use Shopify's theme-check as a starting point for platformOS-lsp
