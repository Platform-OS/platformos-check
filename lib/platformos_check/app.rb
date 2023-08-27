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
    PAGES_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(pages|views/pages)/(.+)}
    PARTIALS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(views/partials|lib)/(.+)}
    LAYOUTS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(views/layouts)/(.+)}
    SCHEMA_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(custom_model_types|model_schemas|schema)/(.+)\.yml\z}
    SMSES_REGEX =  %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(notifications/sms_notifications|smses)/(.+)\.liquid\z}
    USER_SCHEMA_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/)?)user.yml}
    TRANSLATIONS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)translations.+.yml}
    CONFIG_REGEX = %r{(?-mix:^\\/?((marketplace_builder|app)\\/)?)config.yml}

    REGEXP_MAP = {
      API_CALLS_REGEX => ApiCallFile,
      ASSETS_REGEX => AssetFile,
      EMAILS_REGEX => EmailFile,
      GRAPHQL_REGEX => GraphqlFile,
      MIGRATIONS_REGEX => MigrationFile,
      PAGES_REGEX => PageFile,
      PARTIALS_REGEX => PartialFile,
      LAYOUTS_REGEX => LayoutFile,
      SCHEMA_REGEX => SchemaFile,
      SMSES_REGEX => SmsFile,
      USER_SCHEMA_REGEX => UserSchemaFile,
      TRANSLATIONS_REGEX => TranslationFile,
      CONFIG_REGEX => ConfigFile
    }

    attr_reader :storage

    def initialize(storage)
      @storage = storage
    end

    def grouped_files
      @grouped_files ||= begin
        hash = {}
        REGEXP_MAP.each_value { |v| hash[v] = {} }
        storage.files.each do |path|
          regexp, klass = REGEXP_MAP.detect { |k, _v| k.match?(path) }
          if regexp
            f = klass.new(path, storage)
            hash[klass][f.name] = f
          elsif /\.liquid$/i.match?(path)
            hash[LiquidFile] ||= {}
            f = LiquidFile.new(path, storage)
            hash[LiquidFile][f.name] = f
          end
        end
        hash
      end
    end

    def assets
      grouped_files[AssetFile]&.values
    end

    def liquid
      layouts + partials + pages + legacy_liquid + notifications
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

    def layouts
      grouped_files[LayoutFile]&.values || []
    end

    def notifications
      emails + smses + api_calls
    end

    def emails
      grouped_files[EmailFile]&.values || []
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

    def legacy_liquid
      return []

      grouped_files[LiquidFile]&.values || []
    end

    def directories
      storage.directories
    end

    def all
      @all ||= grouped_files.values.map(&:values).flatten
    end

    def [](name_or_relative_path)
      case name_or_relative_path
      when Pathname
        all.find { |t| t.relative_path == name_or_relative_path }
      else
        all.find { |t| t.name == name_or_relative_path }
      end
    end

    def sections
      liquid.select(&:section?)
    end

    def snippets
      liquid.select(&:snippet?)
    end
  end
end
