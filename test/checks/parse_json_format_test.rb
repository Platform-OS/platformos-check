# frozen_string_literal: true

require "test_helper"

class ParseJsonFormatTest < Minitest::Test
  def test_valid
    skip "To be removed"
    offenses = analyze_platformos_app(
      PlatformosCheck::ParseJsonFormat.new(start_level: 1),
      "app/views/pages/index.liquid" => <<~END
        {% parse_json my_json %}
          {
            "hello": "world"
          }
        {% end_parsejson %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_does_not_report_on_invalid_json
    skip "To be removed"
    offenses = analyze_platformos_app(
      PlatformosCheck::ParseJsonFormat.new(start_level: 1),
      "app/views/pages/index.liquid" => <<~END
        {% parse_json my_json %}
          {
            "hello": "world",
          }
        {% end_parsejson %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_reports_offenses
    skip "To be removed"
    offenses = analyze_platformos_app(
      PlatformosCheck::ParseJsonFormat.new(start_level: 1),
      "app/views/pages/index.liquid" => <<~END
        {% parse_json my_json %}
          { "hello": "world" }
        {% end_parsejson %}
      END
    )

    assert_offenses(<<~END, offenses)
      JSON formatting could be improved at app/views/pages/index.liquid:1
    END
  end

  def test_fix_offenses
    skip "To be removed"
    expected_source = {
      "app/views/partials/product.liquid" => <<~END
        {% parse_json my_json %}
          {
            "locales": {
              "en": {
                "title": "Welcome",
                "missing": "Product"
              },
              "fr": {
                "title": "Bienvenue",
                "missing": "TODO"
              }
            }
          }
        {% end_parsejson %}
      END
    }

    source = fix_platformos_app(
      PlatformosCheck::ParseJsonFormat.new(start_level: 1),
      "app/views/partials/product.liquid" => <<~END
        {% parse_json my_json %}
          {
            "locales": {
            "en": {
              "title": "Welcome", "missing": "Product"
            },
                "fr": { "title": "Bienvenue", "missing": "TODO" }
            }
          }
        {% end_parsejson %}
      END
    )

    assert_equal(expected_source, source)
  end
end
