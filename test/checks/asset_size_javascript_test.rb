# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class AssetSizeJavaScriptTest < Minitest::Test
    def test_src_to_file_size
      platformos_app = make_platformos_app({
                                             "assets/platformos_app.js" => "console.log('hello world'); console.log('Oh. Hi Mark!')"
                                           })

      refute_has_file_size("https://{{ settings.url }}", platformos_app)
      refute_has_file_size("{{ 'this_file_does_not_exist.js' | asset_url }}", platformos_app)
      refute_has_file_size("{% if on_product %}https://hello.world{% else %}https://hi.world{% endif %}", platformos_app)

      assert_has_file_size("{{ 'platformos_app.js' | asset_url }}", platformos_app)
      RemoteAssetFile.any_instance.expects(:gzipped_size).times(3).returns(42)

      assert_has_file_size("https://example.com/foo.js", platformos_app)
      assert_has_file_size("http://example.com/foo.js", platformos_app)
      assert_has_file_size("//example.com/foo.js", platformos_app)
    end

    def assert_has_file_size(src, platformos_app)
      check = AssetSizeJavaScript.new
      check.platformos_app = platformos_app
      fs = check.src_to_file_size(src)

      assert(fs, "expected `#{src}` to have a file size.")
    end

    def refute_has_file_size(src, platformos_app)
      check = AssetSizeJavaScript.new
      check.platformos_app = platformos_app
      fs = check.src_to_file_size(src)

      refute(fs, "didn't expect to get a file size for `#{src}`.")
    end

    def test_js_bundles_smaller_than_threshold
      offenses = analyze_platformos_app(
        AssetSizeJavaScript.new(threshold_in_bytes: 10_000_000),
        {
          "assets/platformos_app.js" => <<~JS,
            console.log('hello world');
          JS
          "app/views/pages/index.liquid" => <<~END
            <html>
              <head>
                <script src="{{ 'platformos_app.js' | asset_url }}" defer></script>
              </head>
            </html>
          END
        }
      )

      assert_offenses("", offenses)
    end

    def test_js_bundles_bigger_than_threshold
      offenses = analyze_platformos_app(
        AssetSizeJavaScript.new(threshold_in_bytes: 2),
        "assets/platformos_app.js" => <<~JS,
          console.log('hello world');
        JS
        "app/views/pages/index.liquid" => <<~END
          <html>
            <head>
              <script src="{{ 'platformos_app.js' | asset_url }}" defer></script>
            </head>
          </html>
        END
      )

      assert_offenses(<<~END, offenses)
        JavaScript on every page load exceeds compressed size threshold (2 Bytes), consider using the import on interaction pattern. at app/views/pages/index.liquid:3
      END
    end

    def test_inline_javascript
      offenses = analyze_platformos_app(
        AssetSizeJavaScript.new(threshold_in_bytes: 2),
        "app/views/pages/index.liquid" => <<~END
          <html>
            <head>
              <script>
                console.log('hello world');
              </script>
            </head>
          </html>
        END
      )

      assert_offenses("", offenses)
    end
  end
end
