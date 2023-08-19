# frozen_string_literal: true

require "test_helper"

class ValidYamlTest < Minitest::Test
  def test_detects_yaml_error
    offenses = analyze_platformos_app(
      PlatformosCheck::ValidYaml.new,
      "translations/en/base.yml" => "---\nhello: world\nfail"
    )

    assert_offenses(<<~END, offenses)
      (<unknown>): could not find expected ':' while scanning a simple key at line 3 column 1 at translations/en/base.yml
    END
  end

  def test_valid_yaml
    offenses = analyze_platformos_app(
      PlatformosCheck::ValidYaml.new,
      "translations/en/base.yml" => "---\nhello: world"
    )

    assert_offenses("", offenses)
  end
end
