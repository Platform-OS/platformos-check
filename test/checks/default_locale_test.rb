# frozen_string_literal: true

require "test_helper"

class DefaultLocaleTest < Minitest::Test
  def test_default_locale_file
    offenses = analyze_platformos_app(
      PlatformosCheck::DefaultLocale.new,
      "locales/en.default.json" => "{}"
    )

    assert_empty(offenses)
  end

  def test_default_file_outside_locales
    offenses = analyze_platformos_app(
      PlatformosCheck::DefaultLocale.new,
      "data/en.default.json" => "{}"
    )

    refute_empty(offenses)
  end

  def test_creates_default_file
    platformos_app = make_platformos_app(
      "templates/index.liquid" => <<~END
        <p>
          {{1 + 2}}
        </p>
      END
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::DefaultLocale.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_files = ["locales/en.default.json"]

    assert(missing_files.all? { |file| platformos_app.storage.files.include?(file) })
    assert(platformos_app.storage.read("locales/#{platformos_app.default_locale}.default.json"))
  end
end
