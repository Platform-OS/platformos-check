# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class AssetSizeCSSStylesheetTagTest < Minitest::Test
    def test_css_bundles_smaller_than_threshold
      offenses = analyze_platformos_app(
        AssetSizeCSSStylesheetTag.new(threshold_in_bytes: 10_000_000),
        {
          "assets/platformos_app.css" => <<~JS,
            console.log('hello world');
          JS
          "app/views/pages/index.liquid" => <<~END
            <html>
              <head>
                {{ 'platformos_app.css' | asset_url | stylesheet_tag }}
                {{ "https://example.com" | stylesheet_tag }}
              </head>
            </html>
          END
        }
      )

      assert_offenses("", offenses)
    end

    def test_css_bundles_bigger_than_threshold
      offenses = analyze_platformos_app(
        AssetSizeCSSStylesheetTag.new(threshold_in_bytes: 2),
        "assets/platformos_app.css" => <<~JS,
          console.log('hello world');
        JS
        "app/views/pages/index.liquid" => <<~END
          <html>
            <head>
              {{ 'platformos_app.css' | asset_url | stylesheet_tag }}
              {{ "https://example.com" | stylesheet_tag }}
            </head>
          </html>
        END
      )

      assert_offenses(<<~END, offenses)
        CSS on every page load exceeding compressed size threshold (2 Bytes). at app/views/pages/index.liquid:3
        CSS on every page load exceeding compressed size threshold (2 Bytes). at app/views/pages/index.liquid:4
      END
    end

    def test_no_stylesheet
      offenses = analyze_platformos_app(
        AssetSizeCSSStylesheetTag.new(threshold_in_bytes: 100_000),
        "app/views/pages/index.liquid" => <<~END
          <html>
            <head>
            </head>
          </html>
        END
      )

      assert_offenses("", offenses)
    end
  end
end
