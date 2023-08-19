# frozen_string_literal: true

require "test_helper"

class AnalyzerTest < Minitest::Test
  def setup
    @platformos_app = make_platformos_app(
      "assets/platformos_app.js" => "",
      "assets/platformos_app.css" => "",
      "templates/index.liquid" => "",
      "snippets/product.liquid" => "",
      "sections/article-template/template.liquid" => "",
      "locales/en.default.json" => ""
    )
    @analyzer = PlatformosCheck::Analyzer.new(@platformos_app)
  end

  def test_analyze_platformos_app
    @analyzer.analyze_platformos_app

    refute_empty(@analyzer.offenses)
  end

  def test_analyze_files
    @analyzer.analyze_files(@platformos_app.all)

    refute_empty(@analyzer.offenses)
  end
end
