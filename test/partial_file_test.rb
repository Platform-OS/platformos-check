# frozen_string_literal: true

require "test_helper"

class PartialFileTest < Minitest::Test
  def setup; end

  def test_relative_path
    @app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/index.liquid",
      make_storage("app/views/partials/index.liquid" => '')
    )

    assert_equal("app/views/partials/index.liquid", @app_file.relative_path.to_s)
  end

  def test_type
    @app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/index.liquid",
      make_storage("app/views/partials/index.liquid" => '')
    )

    assert_predicate(@app_file, :partial?)
    refute_predicate(@app_file, :page?)
  end

  def test_name
    @app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/index.liquid",
      make_storage("app/views/partials/index.liquid" => '')
    )

    assert_equal("index", @app_file.name)
  end

  def test_name_in_nested_directories
    @app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/my/subdirectory/index.liquid",
      make_storage("app/views/partials/my/subdirectory/index.liquid" => '')
    )

    assert_equal("my/subdirectory/index", @app_file.name)
  end

  def test_name_in_public_module
    @app_file = PlatformosCheck::PartialFile.new(
      "modules/my_module/public/views/partials/my/subdirectory/index.liquid",
      make_storage("modules/my_module/public/views/partials/my/subdirectory/index.liquid" => '')
    )

    assert_equal("modules/my_module/my/subdirectory/index", @app_file.name)
  end

  def test_name_in_lib_and_private_module
    @app_file = PlatformosCheck::PartialFile.new(
      "modules/my_module/private/lib/my/index.liquid",
      make_storage("modules/my_module/private/lib/my/index.liquid" => '')
    )

    assert_equal("modules/my_module/my/index", @app_file.name)
  end

  def test_excerpt
    @app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/index.liquid",
      make_storage("app/views/partials/index.liquid" => <<~LIQUID)
        <h1>Title</h1>
        <p>
          {{ 1 + 2 }}
        </p>
      LIQUID
    )

    assert_equal("{{ 1 + 2 }}", @app_file.source_excerpt(3))
  end
end
