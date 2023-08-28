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
end
