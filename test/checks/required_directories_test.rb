# frozen_string_literal: true

require "test_helper"

class RequiredDirectories < Minitest::Test
  def test_does_not_report_missing_directories
    offenses = analyze_platformos_app(
      PlatformosCheck::RequiredDirectories.new,
      "assets/gift-card.js" => "",
      "config/settings_data.json" => "",
      "layout/platformos_app.liquid" => "",
      "locales/es.json" => "",
      "sections/footer.liquid" => "",
      "snippets/comment.liquid" => "",
      "templates/index.liquid" => ""
    )

    assert_empty(offenses)
  end

  def test_reports_missing_directories
    offenses = analyze_platformos_app(
      PlatformosCheck::RequiredDirectories.new,
      "assets/gift-card.js" => "",
      "config/settings_data.json" => "",
      "layout/platformos_app.liquid" => "",
      "sections/footer.liquid" => "",
      "snippets/comment.liquid" => "",
      "templates/index.liquid" => ""
    )

    assert_includes_offense(offenses, "App is missing 'locales' directory")
  end

  def test_creates_missing_directories
    platformos_app = make_platformos_app(
      "assets/gift-card.js" => "",
      "config/settings_data.json" => "",
      "layout/platformos_app.liquid" => "",
      "sections/footer.liquid" => "",
      "snippets/comment.liquid" => "",
      "templates/index.liquid" => ""
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::RequiredDirectories.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_directories = ["locales"]

    assert(missing_directories.all? { |file| platformos_app.storage.directories.include?(file) })
  end
end
