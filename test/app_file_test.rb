# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class AppFileTest < Minitest::Test
    def setup
      @platformos_app = make_platformos_app(
        "assets/windows.js" => "console.log(\r\n  hi\r\n)",
        "assets/linux.js" => "console.log(\n  hi\n)",
        "liquid/windows.liquid" => "hello\r\nworld",
        "liquid/linux.liquid" => "hello\nworld",
        "json/windows.json" => "{\r\n  \"a\": \"b\"\r\n}",
        "json/linux.json" => "{\n  \"a\": \"b\"\n}"
      )
    end

    def test_eol_are_always_new_lines_internally
      @platformos_app.liquid.each do |liquid_file|
        assert_equal("hello\nworld", liquid_file.source)
      end
      @platformos_app.json.each do |json_file|
        assert_equal("{\n  \"a\": \"b\"\n}", json_file.source)
      end
      @platformos_app.assets.each do |asset_file|
        assert_equal("console.log(\n  hi\n)", asset_file.source)
      end
    end

    def test_eol_are_maintained_on_template_write
      [
        ["windows", "\r\n"],
        ["linux", "\n"]
      ].each do |(platform, eol)|
        liquid_file = @platformos_app["liquid/#{platform}"]

        assert_equal("hello#{eol}world", @platformos_app.storage.read(liquid_file.relative_path.to_s))
        liquid_file.rewriter.replace(
          node(
            "hello\nworld".index('w'),
            "hello\nworld".index('d') + 1
          ),
          "friend"
        )
        liquid_file.write

        assert_equal("hello#{eol}friend", @platformos_app.storage.read(liquid_file.relative_path.to_s))
      end
    end

    def test_eol_are_maintained_on_json_write
      [
        ["windows", "\r\n"],
        ["linux", "\n"]
      ].each do |(platform, eol)|
        json_file = @platformos_app["json/#{platform}"]

        assert_equal("{#{eol}  \"a\": \"b\"#{eol}}", @platformos_app.storage.read(json_file.relative_path.to_s))
        json_file.content["a"] = "c"
        json_file.write

        assert_equal("{#{eol}  \"a\": \"c\"#{eol}}", @platformos_app.storage.read(json_file.relative_path.to_s))
      end
    end

    def test_eol_are_maintained_on_asset_write
      [
        ["windows", "\r\n"],
        ["linux", "\n"]
      ].each do |(platform, eol)|
        asset_file = @platformos_app["assets/#{platform}.js"]

        assert_equal("console.log(#{eol}  hi#{eol})", @platformos_app.storage.read(asset_file.relative_path.to_s))
        asset_file.rewriter.replace(
          node(
            "console.log(\n  hi\n)".index('hi'),
            "console.log(\n  hi\n)".index('hi') + 2
          ),
          "hello"
        )
        asset_file.write

        assert_equal("console.log(#{eol}  hello#{eol})", @platformos_app.storage.read(asset_file.relative_path.to_s))
      end
    end

    private

    def node(start_index, end_index)
      stub(
        start_index:,
        end_index:
      )
    end
  end
end
