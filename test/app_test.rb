# frozen_string_literal: true

require "test_helper"

class AppTest < Minitest::Test
  def setup
    @platformos_app = make_platformos_app(
      "assets/platformos_app.js" => "",
      "assets/platformos_app.css" => "",
      "templates/index.liquid" => "",
      "snippets/product.liquid" => "",
      "sections/article-template/template.liquid" => "",
      "locales/fr.default.json" => "",
      "locales/en.json" => ""
    )
  end

  def test_all
    assert_equal(7, @platformos_app.all.size)
  end

  def test_assets
    assert_equal(2, @platformos_app.assets.size)
    assert(@platformos_app.assets.all? { |a| a.instance_of?(PlatformosCheck::AssetFile) })
  end

  def test_liquid
    assert_equal(3, @platformos_app.liquid.size)
    assert(@platformos_app.liquid.all? { |a| a.instance_of?(PlatformosCheck::LiquidFile) })
  end

  def test_json
    assert_equal(2, @platformos_app.json.size)
    assert(@platformos_app.json.all? { |a| a.instance_of?(PlatformosCheck::JsonFile) })
  end

  def test_by_name
    assert_equal("assets/platformos_app.css", @platformos_app["assets/platformos_app.css"].name)
    assert_equal("templates/index", @platformos_app["templates/index"].name)
    assert_equal("sections/article-template/template", @platformos_app["sections/article-template/template"].name)
  end

  def test_templates
    assert_equal(["templates/index"], @platformos_app.templates.map(&:name))
  end

  def test_snippets
    assert_equal(["snippets/product"], @platformos_app.snippets.map(&:name))
  end

  def test_sections
    assert_equal(["sections/article-template/template"], @platformos_app.sections.map(&:name))
  end

  def test_default_locale_json
    assert_equal(@platformos_app["locales/fr.default"], @platformos_app.default_locale_json)
  end

  def test_default_locale
    assert_equal("fr", @platformos_app.default_locale)
  end

  def test_ignore
    storage = PlatformosCheck::FileSystemStorage.new(make_file_system_storage(
      "templates/index.liquid" => "",
      "ignored/product.liquid" => "",
      "ignored/nested/product.liquid" => "",
      "locales/en.default.json" => "",
      "locales/nested/en.default.json" => ""
    ).root, ignored_patterns: [
      "ignored/*",
      "*.json"
    ])
    platformos_app = PlatformosCheck::App.new(storage)

    assert_empty(platformos_app.json.map(&:name))
    assert_equal(["templates/index"], platformos_app.liquid.map(&:name))
  end
end
