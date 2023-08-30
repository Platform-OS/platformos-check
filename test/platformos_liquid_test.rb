# frozen_string_literal: true

require "test_helper"

class PlatformosLiquidTest < Minitest::Test
  def test_deprecated_filter_alternatives
    assert_equal(
      %w[color_to_rgb color_modify].sort,
      PlatformosCheck::PlatformosLiquid::DeprecatedFilter.alternatives('hex_to_rgba').sort
    )

    assert_nil(PlatformosCheck::PlatformosLiquid::DeprecatedFilter.alternatives('color_to_rgb'))
  end

  def test_filter_labels
    assert_operator(PlatformosCheck::PlatformosLiquid::Filter.labels.size, :>=, 156)
  end

  def test_object_labels
    assert_operator(PlatformosCheck::PlatformosLiquid::Object.labels.size, :>=, 30)
  end
end
