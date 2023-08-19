# frozen_string_literal: true

require "test_helper"

class MissingTemplateTest < Minitest::Test
  def test_reports_missing_snippet
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "templates/index.liquid" => <<~END
        {% include 'one' %}
        {% render 'two' %}
      END
    )

    assert_offenses(<<~END, offenses)
      'snippets/one.liquid' is not found at templates/index.liquid:1
      'snippets/two.liquid' is not found at templates/index.liquid:2
    END
  end

  def test_do_not_report_if_snippet_exists
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "templates/index.liquid" => <<~END,
        {% include 'one' %}
        {% render 'two' %}
      END
      "snippets/one.liquid" => <<~END,
        hey
      END
      "snippets/two.liquid" => <<~END
        there
      END
    )

    assert_offenses("", offenses)
  end

  def test_reports_missing_section
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "templates/index.liquid" => <<~END
        {% section 'one' %}
      END
    )

    assert_offenses(<<~END, offenses)
      'sections/one.liquid' is not found at templates/index.liquid:1
    END
  end

  def test_do_not_report_if_section_exists
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new,
      "templates/index.liquid" => <<~END,
        {% section 'one' %}
      END
      "sections/one.liquid" => <<~END
        hey
      END
    )

    assert_offenses("", offenses)
  end

  def test_ignore_missing
    offenses = analyze_platformos_app(
      PlatformosCheck::MissingTemplate.new(ignore_missing: [
                                             "snippets/icon-*",
                                             "sections/*"
                                           ]),
      "templates/index.liquid" => <<~END
        {% render 'icon-nope' %}
        {% section 'anything' %}
      END
    )

    assert_offenses("", offenses)
  end

  # Slightly different config, if you top-level ignore all snippets/icon-*,
  # then you should probably also ignore missing templates of all snippets/icon-*
  # See #489 or #589 for more context.
  def test_ignore_config
    check = PlatformosCheck::MissingTemplate.new

    # this is what config.rb would do
    check.ignored_patterns = [
      "snippets/icon-*",
      "sections/*"
    ]

    offenses = analyze_platformos_app(
      check,
      "templates/index.liquid" => <<~END
        {% render 'icon-nope' %}
        {% section 'anything' %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_creates_missing_snippet
    platformos_app = make_platformos_app(
      "templates/index.liquid" => <<~END
        {% include 'one' %}
        {% render 'two' %}
      END
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::MissingTemplate.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_files = ["snippets/one.liquid", "snippets/two.liquid"]

    assert(missing_files.all? { |file| platformos_app.storage.files.include?(file) })
  end

  def test_creates_missing_section
    platformos_app = make_platformos_app(
      "templates/index.liquid" => <<~END
        {% section 'one' %}
      END
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::MissingTemplate.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_files = ["sections/one.liquid"]

    assert(missing_files.all? { |file| platformos_app.storage.files.include?(file) })
  end
end
