# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class AssetSizeCSSTest < Minitest::Test
    def setup
      skip "To be removed"
      @extension_files = {
        "assets/app.css" => "* { color: green } ",
        "app/views/partials/app.liquid" => <<~BLOCK

          {% schema %}
          {
            "stylesheet": "app.css"
          }
          {% endschema %}
        BLOCK
      }
    end

    def test_css_smaller_than_threshold
      offenses = analyze_platformos_app(
        AssetSizeAppBlockCSS.new(threshold_in_bytes: 10_000_000),
        @extension_files
      )

      assert_offenses("", offenses)
    end

    def test_css_larger_than_threshold
      offenses = analyze_platformos_app(
        AssetSizeAppBlockCSS.new(threshold_in_bytes: 1),
        @extension_files
      )

      assert_offenses(<<~END, offenses)
        CSS in App Extension blocks exceeds compressed size threshold (1 Bytes) at blocks/app.liquid:2
      END
    end
  end
end
