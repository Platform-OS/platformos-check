# frozen_string_literal: true

require "test_helper"

class AppTest < Minitest::Test
  def setup
    @platformos_app = make_platformos_app(
      "app/assets/app.js" => "",
      "app/assets/app.css" => "",
      "app/assets/logo.svg" => "",
      "modules/my-module/public/assets/logo.svg" => "",
      "schema/car.yml" => "",
      "schema/employee.yml" => "",
      "modules/my-module/private/model_schema/payroll.yml" => "",
      "app/emails/employee/welcome.liquid" => "",
      "app/api_calls/slack/send_message_to_channel.liquid" => "",
      "app/smses/employee/notify_otp.liquid" => "",
      "app/graphql/cars/create.graphql" => "",
      "app/graphql/employee/search.graphql" => "",
      "app/views/pages/index.liquid" => "",
      "app/views/pages/car/index.liquid" => "",
      "app/views/layouts/application.liquid" => "",
      "app/views/layouts/admin.liquid" => "",
      "app/views/layouts/dashboard.liquid" => "",
      "app/views/partials/cars/card.liquid" => "",
      "app/views/partials/footer.liquid" => "",
      "app/lib/calculate_salary.liquid" => "",
      "app/translations/en/base.yml" => "",
      "app/translations/en/car.yml" => "",
      "app/translations/de/car.yml" => "",
      "app/config.yml" => "",
      "app/user.yml" => ""
    )
  end

  def test_all
    assert_equal(24, @platformos_app.all.size)
  end

  def test_assets
    assert_equal(4, @platformos_app.assets.size)
    assert(@platformos_app.assets.all? { |a| a.instance_of?(PlatformosCheck::AssetFile) })
  end

  def test_liquid
    assert_equal(11, @platformos_app.liquid.size)
    assert(@platformos_app.liquid.all? { |a| a.is_a?(PlatformosCheck::LiquidFile) })
  end

  def test_by_name
    assert_equal("app.js", @platformos_app["app/assets/app.js"].name)
    assert_equal("cars/card", @platformos_app["app/views/partials/cars/card.liquid"].name)
    assert_equal("app/views/pages/index", @platformos_app["app/views/pages/index.liquid"].name)
  end

  def test_ignore
    storage = PlatformosCheck::FileSystemStorage.new(make_file_system_storage(
      "app/assets/app.js" => "",
      "app/assets/app.css" => "",
      "modules/my-module/public/assets/logo.svg" => "",
      "schema/car.yml" => "",
      "schema/employee.yml" => "",
      "modules/my-module/private/model_schema/payroll.yml" => "",
      "app/emails/employee/welcome.liquid" => "",
      "app/api_calls/slack/send_message_to_channel.liquid" => "",
      "app/smses/employee/notify_otp.liquid" => "",
      "app/graphql/cars/create.graphql" => "",
      "app/graphql/employee/search.graphql" => "",
      "app/views/pages/index.liquid" => "",
      "app/views/pages/car/index.liquid" => "",
      "app/views/layouts/application.liquid" => "",
      "app/views/layouts/admin.liquid" => "",
      "app/views/layouts/dashboard.liquid" => "",
      "app/views/partials/cars/card.liquid" => "",
      "app/views/partials/footer.liquid" => "",
      "app/lib/calculate_salary.liquid" => "",
      "app/translations/en/base.yml" => "",
      "app/translations/en/car.yml" => "",
      "app/translations/de/car.yml" => "",
      "app/config.yml" => "",
      "app/user.yml" => ""
    ).root, ignored_patterns: [
      "modules/my-module/*",
      "*.yaml"
    ])

    assert_equal(["app.css", "app.js"], storage.platformos_app.assets.map(&:name).sort)
  end

  def test_module_overwrites_in_app
    # find the overwrite in app instead of the original file in modules
    @platformos_app = make_platformos_app(
      "modules/my-module/public/lib/foo/create.liquid" => "modules",
      "app/modules/my-module/public/lib/foo/create.liquid" => "app"
    )

    assert_equal '/dev/null/app/modules/my-module/public/lib/foo/create.liquid', @platformos_app.grouped_files[PlatformosCheck::PartialFile]["modules/my-module/foo/create"].path.to_s

    # find the overwrite in app instead of the original file in modules
    @platformos_app = make_platformos_app(
      "app/modules/my-module/public/lib/foo/create.liquid" => "app",
      "modules/my-module/public/lib/foo/create.liquid" => "modules"
    )

    assert_equal '/dev/null/app/modules/my-module/public/lib/foo/create.liquid', @platformos_app.grouped_files[PlatformosCheck::PartialFile]["modules/my-module/foo/create"].path.to_s

    # find the original file in modules if the overwrite is missing
    @platformos_app = make_platformos_app(
      "modules/my-module/public/lib/foo/create.liquid" => "modules"
    )

    assert_equal(1, @platformos_app.liquid.size)
    assert(@platformos_app.liquid.all? { |a| a.is_a?(PlatformosCheck::LiquidFile) })

    assert_equal '/dev/null/modules/my-module/public/lib/foo/create.liquid', @platformos_app.grouped_files[PlatformosCheck::PartialFile]["modules/my-module/foo/create"].path.to_s

    # find the overwrite file in modules even if the original is missing
    @platformos_app = make_platformos_app(
      "app/modules/my-module/public/lib/foo/create.liquid" => "app"
    )

    assert_equal '/dev/null/app/modules/my-module/public/lib/foo/create.liquid', @platformos_app.grouped_files[PlatformosCheck::PartialFile]["modules/my-module/foo/create"].path.to_s
  end
end
