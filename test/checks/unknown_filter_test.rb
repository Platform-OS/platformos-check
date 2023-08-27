# frozen_string_literal: true

require "test_helper"

class UnknownFilterTest < Minitest::Test
  def test_reports_on_unknown_filter
    offenses = analyze_platformos_app(
      PlatformosCheck::UnknownFilter.new,
      "app/views/pages/index.liquid" => <<~END
        {{ "foo" | bar }}
      END
    )

    assert_offenses(<<~END, offenses)
      Undefined filter `bar` at app/views/pages/index.liquid:1
    END
  end

  def test_reports_on_unknown_filter_chained_with_known_filters
    offenses = analyze_platformos_app(
      PlatformosCheck::UnknownFilter.new,
      "app/views/pages/index.liquid" => <<~END
        {{ "foo" | append: ".js" | bar }}
      END
    )

    assert_offenses(<<~END, offenses)
      Undefined filter `bar` at app/views/pages/index.liquid:1
    END
  end

  def test_reports_does_not_report_on_known_filter
    offenses = analyze_platformos_app(
      PlatformosCheck::UnknownFilter.new,
      "app/views/pages/index.liquid" => <<~END
        {{ "foo" | upcase }}
      END
    )

    assert_empty(offenses)
  end

  def test_reports_does_not_report_on_chain_of_known_filter
    offenses = analyze_platformos_app(
      PlatformosCheck::UnknownFilter.new,
      "app/views/pages/index.liquid" => <<~END
        {{ "foo" | append: ".js" | upcase }}
      END
    )

    assert_empty(offenses)
  end
end
