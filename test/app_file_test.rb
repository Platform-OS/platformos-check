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
        "translations/en/base.yml" => "---\r\n  a: \"b\"\r\n",
        "translations/de/base.yml" => "---\n  a: b\n"
      )
    end

    def test_eol_are_always_new_lines_internally
      @platformos_app.liquid.each do |liquid_file|
        assert_equal("hello\nworld", liquid_file.source)
      end
      @platformos_app.yaml.each do |yaml_file|
        assert_equal({ "a" => "b" }, YAML.load(yaml_file.source))
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

    def test_eol_are_maintained_on_yaml_write
      [
        ["translations/en/base", "\r\n", "---\r\n  a: \"b\"\r\n"],
        ["translations/de/base", "\n", "---\n  a: b\n"]
      ].each do |(platform, eol, content)|
        yaml_file = @platformos_app[platform]

        assert_equal(content, @platformos_app.storage.read(yaml_file.relative_path.to_s))
        yaml_file.content["a"] = "c"
        yaml_file.write

        assert_equal("---#{eol}a: c#{eol}\n", @platformos_app.storage.read(yaml_file.relative_path.to_s))
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
