# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class AssetSizeCSSTest < Minitest::Test
    def test_href_to_file_size
      platformos_app = make_platformos_app({
                                             "assets/platformos_app.css" => "* { color: green !important; }"
                                           })

      assert_has_file_size("{{ 'platformos_app.css' | asset_url }}", platformos_app)
      RemoteAssetFile.any_instance.expects(:gzipped_size).times(3).returns(42)

      assert_has_file_size("https://example.com/foo.css", platformos_app)
      assert_has_file_size("http://example.com/foo.css", platformos_app)
      assert_has_file_size("//example.com/foo.css", platformos_app)

      refute_has_file_size("{{ 'this_file_does_not_exist.css' | asset_url }}", platformos_app)
      refute_has_file_size("{% if on_product %}https://hello.world{% else %}https://hi.world{% endif %}", platformos_app)
    end

    def assert_has_file_size(href, platformos_app)
      check = AssetSizeCSS.new
      check.platformos_app = platformos_app
      fs = check.href_to_file_size(href)

      assert(fs, "expected `#{href}` to have a file size.")
    end

    def refute_has_file_size(href, platformos_app)
      check = AssetSizeCSS.new
      check.platformos_app = platformos_app
      fs = check.href_to_file_size(href)

      refute(fs, "didn't expect to get a file size for `#{href}`.")
    end

    def test_css_bundles_smaller_than_threshold
      offenses = analyze_platformos_app(
        AssetSizeCSS.new(threshold_in_bytes: 10_000_000),
        {
          "assets/platformos_app.css" => <<~JS,
            console.log('hello world');
          JS
          "app/views/pages/index.liquid" => <<~END
            <html>
              <head>
                <link href="{{ 'platformos_app.css' | asset_url }}" rel="stylesheet">
              </head>
            </html>
          END
        }
      )

      assert_offenses("", offenses)
    end

    def test_css_bundles_bigger_than_threshold
      offenses = analyze_platformos_app(
        AssetSizeCSS.new(threshold_in_bytes: 2),
        "assets/platformos_app.css" => <<~JS,
          console.log('hello world');
        JS
        "app/views/pages/index.liquid" => <<~END
          <html>
            <head>
              <link href="{{ 'platformos_app.css' | asset_url }}" rel="stylesheet">
            </head>
          </html>
        END
      )

      assert_offenses(<<~END, offenses)
        CSS on every page load exceeding compressed size threshold (2 Bytes) at app/views/pages/index.liquid:3
      END
    end
  end
end
