# frozen_string_literal: true

require "test_helper"

class PartialFileTest < Minitest::Test
  def setup; end

  def test_relative_path
    @platformos_app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/index.liquid",
      make_storage("app/views/partials/index.liquid" => '')
    )

    assert_equal("app/views/partials/index.liquid", @platformos_app_file.relative_path.to_s)
  end

  def test_type
    @platformos_app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/index.liquid",
      make_storage("app/views/partials/index.liquid" => '')
    )

    assert_predicate(@platformos_app_file, :partial?)
    refute_predicate(@platformos_app_file, :page?)
  end

  def test_name
    @platformos_app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/index.liquid",
      make_storage("app/views/partials/index.liquid" => '')
    )

    assert_equal("index", @platformos_app_file.name)
  end

  def test_name_in_nested_directories
    @platformos_app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/my/subdirectory/index.liquid",
      make_storage("app/views/partials/my/subdirectory/index.liquid" => '')
    )

    assert_equal("my/subdirectory/index", @platformos_app_file.name)
  end

  def test_name_in_public_module
    @platformos_app_file = PlatformosCheck::PartialFile.new(
      "modules/my_module/public/views/partials/my/subdirectory/index.liquid",
      make_storage("modules/my_module/public/views/partials/my/subdirectory/index.liquid" => '')
    )

    assert_equal("modules/my_module/my/subdirectory/index", @platformos_app_file.name)
  end

  def test_name_in_lib_and_private_module
    @platformos_app_file = PlatformosCheck::PartialFile.new(
      "modules/my_module/private/lib/my/index.liquid",
      make_storage("modules/my_module/private/lib/my/index.liquid" => '')
    )

    assert_equal("modules/my_module/my/index", @platformos_app_file.name)
  end

  def test_excerpt
    @platformos_app_file = PlatformosCheck::PartialFile.new(
      "app/views/partials/index.liquid",
      make_storage("app/views/partials/index.liquid" => <<~LIQUID)
        <h1>Title</h1>
        <p>
          {{ 1 + 2 }}
        </p>
      LIQUID
    )

    assert_equal("{{ 1 + 2 }}", @platformos_app_file.source_excerpt(3))
  end
end
