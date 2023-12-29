# frozen_string_literal: true

require "test_helper"

class MissingTemplateTest < Minitest::Test
  def test_reports_missing_partial
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END
        {% include 'one' %}
        {% render 'two' %}
      END
    )

    assert_offenses(<<~END, offenses)
      'one' is not found at app/views/pages/index.liquid:1
      'two' is not found at app/views/pages/index.liquid:2
    END
  end

  def test_reports_missing_module_partial
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END
        {% include 'modules/my-module/one' %}
        {% render 'modules/my-module/two' %}
      END
    )

    assert_offenses(<<~END, offenses)
      'modules/my-module/one' is not found at app/views/pages/index.liquid:1
      'modules/my-module/two' is not found at app/views/pages/index.liquid:2
    END
  end

  def test_do_not_report_if_partial_exists
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END,
        {% include 'one' %}
        {% render 'two' %}
      END
      "app/views/partials/one.liquid" => <<~END,
        hey
      END
      "app/views/partials/two.liquid" => <<~END
        there
      END
    )

    assert_offenses("", offenses)
  end

  def test_do_not_report_if_module_partial_exists
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END,
        {% include 'modules/my-module/one' %}
        {% render 'modules/my-module/two' %}
      END
      "modules/my-module/public/views/partials/one.liquid" => <<~END,
        hey
      END
      "modules/my-module/private/views/partials/two.liquid" => <<~END
        there
      END
    )

    assert_offenses("", offenses)
  end

  def test_report_if_module_partial_not_in_public_or_private
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END,
        {% include 'modules/my-module/one' %}
        {% render 'modules/my-module/two' %}
      END
      "modules/my-module/views/partials/one.liquid" => <<~END,
        hey
      END
      "modules/my-module/lib/two.liquid" => <<~END
        there
      END
    )

    assert_offenses(<<~END, offenses)
      'modules/my-module/one' is not found at app/views/pages/index.liquid:1
      'modules/my-module/two' is not found at app/views/pages/index.liquid:2
    END
  end

  def test_reports_missing_function
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END
        {% function res = 'one' %}
      END
    )

    assert_offenses(<<~END, offenses)
      'one' is not found at app/views/pages/index.liquid:1
    END
  end

  def test_do_not_report_if_function_exists
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END,
        {% function res = 'one' %}
      END
      "app/lib/one.liquid" => <<~END
        hey
      END
    )

    assert_offenses("", offenses)
  end

  def test_do_not_report_if_variable_used_for_function_name
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END,
        {% assign function_name = 'two' %}
        {% function res = function_name %}
      END
      "app/lib/one.liquid" => <<~END
        hey
      END
    )

    assert_offenses("", offenses)
  end

  def test_reports_missing_graphql
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END
        {% graphql res = 'users/search' %}
      END
    )

    assert_offenses(<<~END, offenses)
      'users/search' is not found at app/views/pages/index.liquid:1
    END
  end

  def test_ignore_inline_graphql
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END
        {% graphql res %}
          query records {
            records(per_page: 20, table: "my_table") {
              results {
                id
              }
            }
          }
        {% endgraphql %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_do_not_report_if_graphql_exists
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "app/views/pages/index.liquid" => <<~END,
        {% graphql res = 'users/search' %}
      END
      "app/graphql/users/search.graphql" => ''
    )

    assert_offenses("", offenses)
  end

  def test_ignore_missing
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new(ignore_missing: [
                                             "icon-*",
                                             "functions/*"
                                           ]),
      "app/views/pages/index.liquid" => <<~END
        {% render 'icon-nope' %}
        {% function res = 'functions/anything' %}
      END
    )

    assert_offenses("", offenses)
  end

  # Slightly different config, if you top-level ignore all app/views/partials/icon-*,
  # then you should probably also ignore missing app/views/pages of all app/views/partials/icon-*
  # See #489 or #589 for more context.
  def test_ignore_config
    check = PlatformosCheck::MissingTemplate.new

    # this is what config.rb would do
    check.ignored_patterns = [
      "icon-*",
      "functions/*"
    ]

    offenses = analyze_platformos_app(
      check,
      "app/views/pages/index.liquid" => <<~END
        {% render 'icon-nope' %}
        {% function res = 'functions/anything' %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_creates_missing_partial
    skip "Commented out ; need to support template-values.json first etc."
    platformos_app = make_platformos_app(
      "app/views/pages/index.liquid" => <<~END
        {% include 'one' %}
        {% render 'two' %}
      END
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::MissingTemplate.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_files = ["app/views/partials/one.liquid", "app/views/partials/two.liquid"]

    assert(missing_files.all? { |file| platformos_app.storage.files.include?(file) })
  end

  def test_creates_missing_graphql
    skip "Commented out ; need to support template-values.json first etc."
    platformos_app = make_platformos_app(
      "app/views/pages/index.liquid" => <<~END
        {% graphql res = 'users/search' %}
      END
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::MissingTemplate.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_files = ["app/graphql/users/search.graphql"]

    assert(missing_files.all? { |file| platformos_app.storage.files.include?(file) })
  end

  def test_creates_missing_function
    skip "Commented out ; need to support template-values.json first etc."
    platformos_app = make_platformos_app(
      "app/views/pages/index.liquid" => <<~END
        {% function res = 'one' %}
      END
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::MissingTemplate.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_files = ["app/lib/one.liquid"]

    assert(missing_files.all? { |file| platformos_app.storage.files.include?(file) })
  end

  def test_creates_missing_module_function
    skip "Commented out ; need to support template-values.json first etc."
    platformos_app = make_platformos_app(
      "app/views/pages/index.liquid" => <<~END
        {% function res = 'modules/my-module/one' %}
      END
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::MissingTemplate.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_files = ["modules/my-module/public/lib/one.liquid"]

    assert(missing_files.all? { |file| platformos_app.storage.files.include?(file) })
  end

  def test_creates_missing_module_graphql
    skip "Commented out ; need to support template-values.json first etc."
    platformos_app = make_platformos_app(
      "app/views/pages/index.liquid" => <<~END
        {% graphql res = 'modules/my-module/users/search' %}
      END
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::MissingTemplate.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_files = ["modules/my-module/public/graphql/users/search.graphql"]

    assert(missing_files.all? { |file| platformos_app.storage.files.include?(file) })
  end
end
