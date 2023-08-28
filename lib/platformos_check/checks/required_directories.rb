# frozen_string_literal: true

module PlatformosCheck
  # Reports missing shopify required directories

  class RequiredDirectories < LiquidCheck
    DeprecatedDirectory = Struct.new(:old_path, :new_path)

    severity :error
    category :liquid
    doc docs_url(__FILE__)

    REQUIRED_DIRECTORIES = %w[app/assets app/translations app/views/pages app/views/partials app/lib app/emails app/smses app/api_calls app/views/layouts app/schema app/graphql]
    DEPRECATION_MAP = {
      'app/schema' => %w[app/model_schemas],
      'app/smses' => %w[app/notifications/sms_notifications],
      'app/emails' => %w[app/notifications/email_notifications],
      'app/api_calls' => %w[app/notifications/api_call_notifications]
    }

    def on_end
      directories = platformos_app.directories.map(&:to_s)
      missing_directories = REQUIRED_DIRECTORIES - directories
      deprecated_directories = missing_directories.each_with_object([]) do |new_path, arr|
        next unless DEPRECATION_MAP[new_path]

        old_path = DEPRECATION_MAP[new_path].detect { |dir| directories.include?(dir) }
        arr << DeprecatedDirectory.new(old_path:, new_path:) if old_path
      end
      missing_directories.each { |d| add_missing_directories_offense(d) }
      deprecated_directories.each { |d| add_deprecated_directories_offense(d) }
    end

    private

    def add_missing_directories_offense(directory)
      add_offense("App is missing '#{directory}' directory") do |corrector|
        corrector.mkdir(@platformos_app.storage, directory)
      end
    end

    def add_deprecated_directories_offense(deprecated_directory)
      add_offense("App is using deprecated directory name '#{deprecated_directory.old_path}' instead of '#{deprecated_directory.new_path}'")
    end
  end
end
