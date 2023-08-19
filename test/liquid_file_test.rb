# frozen_string_literal: true

require "test_helper"

class LiquidFileTest < Minitest::Test
  def setup
    @platformos_app_file = PlatformosCheck::LiquidFile.new(
      "templates/index.liquid",
      make_storage("templates/index.liquid" => <<~LIQUID)
        <h1>Title</h1>
        <p>
          {{ 1 + 2 }}
        </p>
      LIQUID
    )
  end

  def test_relative_path
    assert_equal("templates/index.liquid", @platformos_app_file.relative_path.to_s)
  end

  def test_type
    assert_predicate(@platformos_app_file, :template?)
    refute_predicate(@platformos_app_file, :snippet?)
  end

  def test_name
    assert_equal("templates/index", @platformos_app_file.name)
  end

  def test_excerpt
    assert_equal("{{ 1 + 2 }}", @platformos_app_file.source_excerpt(3))
  end
end
