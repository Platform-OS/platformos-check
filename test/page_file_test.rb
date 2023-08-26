# frozen_string_literal: true

require "test_helper"

class LiquidFileTest < Minitest::Test
  def setup
    @platformos_app_file = PlatformosCheck::PageFile.new(
      "app/views/pages/index.liquid",
      make_storage("app/views/pages/index.liquid" => <<~LIQUID)
        <h1>Title</h1>
        <p>
          {{ 1 + 2 }}
        </p>
      LIQUID
    )
  end

  def test_relative_path
    assert_equal("app/views/pages/index.liquid", @platformos_app_file.relative_path.to_s)
  end

  def test_type
    assert_predicate(@platformos_app_file, :page?)
    refute_predicate(@platformos_app_file, :partial?)
  end

  def test_name
    assert_equal("app/views/pages/index", @platformos_app_file.name)
  end

  def test_excerpt
    assert_equal("{{ 1 + 2 }}", @platformos_app_file.source_excerpt(3))
  end
end
