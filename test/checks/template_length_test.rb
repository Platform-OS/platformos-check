# frozen_string_literal: true

require "test_helper"

class TemplateLengthTest < Minitest::Test
  def test_finds_unused
    offenses = analyze_platformos_app(
      PlatformosCheck::TemplateLength.new(max_length: 10),
      "app/views/pages/long.liquid" => <<~END,
        #{"\n" * 10}
      END
      "app/views/pages/short.liquid" => <<~END
        #{"\n" * 9}
      END
    )

    assert_offenses(<<~END, offenses)
      Template has too many lines [11/10] at app/views/pages/long.liquid
    END
  end

  def test_excludes_lines_inside_schema
    skip "To be removed"
    offenses = analyze_platformos_app(
      PlatformosCheck::TemplateLength.new(max_length: 10, exclude_schema: true),
      "sections/long.liquid" => <<~END
        {% schema %}
          #{"\n" * 10}
        {% endschema %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_excludes_lines_inside_stylesheet
    skip "To be removed"
    offenses = analyze_platformos_app(
      PlatformosCheck::TemplateLength.new(max_length: 10, exclude_stylesheet: true),
      "sections/long.liquid" => <<~END
        {% stylesheet %}
          #{"\n" * 10}
        {% endstylesheet %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_excludes_lines_inside_javascript
    skip "To be removed"
    offenses = analyze_platformos_app(
      PlatformosCheck::TemplateLength.new(max_length: 10, exclude_javascript: true),
      "sections/long.liquid" => <<~END
        {% javascript %}
          #{"\n" * 10}
        {% endjavascript %}
      END
    )

    assert_offenses("", offenses)
  end
end
