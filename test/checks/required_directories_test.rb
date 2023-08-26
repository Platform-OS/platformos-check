# frozen_string_literal: true

require "test_helper"

class RequiredDirectories < Minitest::Test
  def test_does_not_report_missing_directories
    offenses = analyze_platformos_app(
      PlatformosCheck::RequiredDirectories.new,
      "app/assets/app.js" => "",
      "app/assets/app.css" => "",
      "app/assets/logo.svg" => "",
      "modules/my-module/public/assets/logo.svg" => "",
      "app/schema/car.yml" => "",
      "app/schema/employee.yml" => "",
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

    assert_empty(offenses)
  end

  def test_reports_missing_directories
    offenses = analyze_platformos_app(
      PlatformosCheck::RequiredDirectories.new,
      "app/assets/app.js" => "",
      "app/assets/app.css" => "",
      "app/assets/logo.svg" => "",
      "modules/my-module/public/assets/logo.svg" => "",
      "app/schema/car.yml" => "",
      "app/schema/employee.yml" => "",
      "modules/my-module/private/model_schema/payroll.yml" => "",
      "app/emails/employee/welcome.liquid" => "",
      "app/api_calls/slack/send_message_to_channel.liquid" => "",
      "app/smses/employee/notify_otp.liquid" => "",
      "app/graphql/cars/create.graphql" => "",
      "app/graphql/employee/search.graphql" => "",
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

    assert_includes_offense(offenses, "App is missing 'app/views/pages' directory")
  end

  def test_reports_deprecated_directories
    offenses = analyze_platformos_app(
      PlatformosCheck::RequiredDirectories.new,
      "app/assets/app.js" => "",
      "app/assets/app.css" => "",
      "app/assets/logo.svg" => "",
      "modules/my-module/public/assets/logo.svg" => "",
      "app/model_schemas/car.yml" => "",
      "app/model_schemas/employee.yml" => "",
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

    assert_includes_offense(offenses, "App is using deprecated directory name 'app/model_schemas' instead of 'app/schema'")
  end

  def test_rename_deprecated_directories
    skip "TODO: to be implemented"
    platformos_app = make_platformos_app(
      "app/assets/app.js" => "",
      "app/assets/app.css" => "",
      "app/assets/logo.svg" => "",
      "modules/my-module/public/assets/logo.svg" => "",
      "app/model_schemas/car.yml" => "",
      "app/model_schemas/employee.yml" => "",
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

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::RequiredDirectories.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    deprecated_directories = [["app/model_schemas", 'app/schema']]

    assert(deprecated_directories.all? { |file_paths| platformos_app.storage.directories.include?(file_paths[1]) })
    assert(deprecated_directories.all? { |file_paths| !platformos_app.storage.directories.include?(file_paths[0]) })
  end

  def test_creates_missing_directories
    platformos_app = make_platformos_app(
      "app/assets/app.js" => "",
      "app/assets/app.css" => "",
      "app/assets/logo.svg" => "",
      "modules/my-module/public/assets/logo.svg" => "",
      "app/schema/car.yml" => "",
      "app/schema/employee.yml" => "",
      "modules/my-module/private/model_schema/payroll.yml" => "",
      "app/emails/employee/welcome.liquid" => "",
      "app/api_calls/slack/send_message_to_channel.liquid" => "",
      "app/smses/employee/notify_otp.liquid" => "",
      "app/graphql/cars/create.graphql" => "",
      "app/graphql/employee/search.graphql" => "",
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

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::RequiredDirectories.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    missing_directories = ["app/views/pages"]

    assert(missing_directories.all? { |file| platformos_app.storage.directories.include?(file) })
  end
end
