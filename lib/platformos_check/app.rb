# frozen_string_literal: true

# frozen_string_lite/al: true

require "pathname"

module PlatformosCheck
  class App
    API_CALLS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(notifications/api_call_notifications|api_calls)/(.+)\.liquid\z}
    ASSETS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)assets/}
    EMAILS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(notifications/email_notifications|emails)/(.+)\.liquid\z}
    GRAPHQL_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(graph_queries|graphql)s?/(.+)\.graphql\z}

    MIGRATIONS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)migrations/(.+)\.liquid\z}
    PAGES_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(pages|views/pages)/(.+).liquid\z}
    PARTIALS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(views/partials|lib)/(.+)\.liquid\z}
    FORMS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(form_configurations|forms)/(.+)\.liquid\z}
    LAYOUTS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(views/layouts)/(.+).liquid\z}
    SCHEMA_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(custom_model_types|model_schemas|schema)/(.+)\.yml\z}
    SMSES_REGEX =  %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(notifications/sms_notifications|smses)/(.+)\.liquid\z}
    USER_SCHEMA_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/)?)user.yml}
    TRANSLATIONS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)translations/(.+)\.yml}
    CONFIG_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/)?)config.yml}

    REGEXP_MAP = {
      API_CALLS_REGEX => ApiCallFile,
      ASSETS_REGEX => AssetFile,
      EMAILS_REGEX => EmailFile,
      GRAPHQL_REGEX => GraphqlFile,
      MIGRATIONS_REGEX => MigrationFile,
      PAGES_REGEX => PageFile,
      PARTIALS_REGEX => PartialFile,
      FORMS_REGEX => FormFile,
      LAYOUTS_REGEX => LayoutFile,
      SCHEMA_REGEX => SchemaFile,
      SMSES_REGEX => SmsFile,
      USER_SCHEMA_REGEX => UserSchemaFile,
      TRANSLATIONS_REGEX => TranslationFile,
      CONFIG_REGEX => ConfigFile
    }

    attr_reader :storage, :grouped_files

    def initialize(storage)
      @storage = storage
      @grouped_files = {}
      REGEXP_MAP.each_value { |v| @grouped_files[v] ||= {} }
      process_files(storage.files)
    end

    def update(files, remove: false)
      process_files(files, remove:)
    end

    def process_files(files, remove: false)
      files.each do |path|
        regexp, klass = REGEXP_MAP.detect { |k, _v| k.match?(path) }
        next unless regexp

        f = klass.new(path, storage)
        if remove
          @grouped_files[klass].delete(f.name)
        else
          @grouped_files[klass][f.name] = f
        end
      end
      @grouped_files
    end

    def assets
      grouped_files[AssetFile]&.values
    end

    def liquid
      layouts + partials + forms + pages + notifications
    end

    def yaml
      schema + translations
    end

    def schema
      grouped_files[SchemaFile]&.values || []
    end

    def translations
      grouped_files[TranslationFile]&.values || []
    end

    def partials
      grouped_files[PartialFile]&.values || []
    end

    def forms
      grouped_files[FormFile]&.values || []
    end

    def layouts
      grouped_files[LayoutFile]&.values || []
    end

    def notifications
      emails + smses + api_calls
    end

    def emails
      grouped_files[EmailFile]&.values || []
    end

    def graphqls
      grouped_files[GraphqlFile]&.values || []
    end

    def smses
      grouped_files[SmsFile]&.values || []
    end

    def api_calls
      grouped_files[ApiCallFile]&.values || []
    end

    def pages
      grouped_files[PageFile]&.values || []
    end

    def app_config
      grouped_files[ConfigFile]&.values&.first
    end

    def all
      grouped_files.values.map(&:values).flatten
    end

    def [](name_or_relative_path)
      case name_or_relative_path
      when Pathname
        all.find { |t| t.relative_path == name_or_relative_path }
      else
        all.find { |t| t.relative_path.to_s == name_or_relative_path }
      end
    end
  end
end
