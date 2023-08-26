# frozen_string_literal: true

require "pathname"

module PlatformosCheck
  class App
    API_CALLS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(notifications/api_call_notifications|api_calls)/(.+)\.liquid\z}
    ASSETS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)assets/}
    EMAILS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(notifications/email_notifications|emails)/(.+)\.liquid\z}
    GRAPHQL_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(graph_queries|graphql)s?/(.+)\.graphql\z}

    MIGRATIONS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)migrations/(.+)\.liquid\z}
    PAGES_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(pages|views/pages)/(.+)}
    PARTIALS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(views/partials|views/layouts|lib)/(.+)}
    SCHEMA_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(custom_model_types|model_schemas|schema)/(.+)\.yml\z}
    SMSES_REGEX =  %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)(notifications/sms_notifications|smses)/(.+)\.liquid\z}
    USER_SCHEMA_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/)?)user.yml}
    TRANSLATIONS_REGEX = %r{\A(?-mix:^/?((marketplace_builder|app)/|modules/(.+)(private|public|marketplace_builder|app)/)?)translations.+.yml}
    CONFIG_REGEX = %r{(?-mix:^\\/?((marketplace_builder|app)\\/)?)config.yml}

    attr_reader :storage

    def initialize(storage)
      @storage = storage
    end

    def grouped_files
      @grouped_files ||= begin
        hash = {}
        storage.files.each do |path|
          if ASSETS_REGEX.match?(path)
            hash['assets'] ||= []
            hash['assets'] << AssetFile.new(path, storage)
          elsif PARTIALS_REGEX.match?(path)
            hash['partials'] ||= []
            hash['partials'] << PartialFile.new(path, storage)
          elsif PAGES_REGEX.match?(path)
            hash['pages'] ||= []
            hash['pages'] << PageFile.new(path, storage)
          elsif GRAPHQL_REGEX.match?(path)
            hash['graphql'] ||= []
            hash['graphql'] << GraphqlFile.new(path, storage)
          elsif SCHEMA_REGEX.match?(path)
            hash['schema'] ||= []
            hash['schema'] << YamlFile.new(path, storage)
          elsif SMSES_REGEX.match?(path)
            hash['smses'] ||= []
            hash['smses'] << SmsFile.new(path, storage)
          elsif EMAILS_REGEX.match?(path)
            hash['emails'] ||= []
            hash['emails'] << EmailFile.new(path, storage)
          elsif API_CALLS_REGEX.match?(path)
            hash['api_calls'] ||= []
            hash['api_calls'] << ApiCallFile.new(path, storage)
          elsif TRANSLATIONS_REGEX.match?(path)
            hash['translations'] ||= []
            hash['translations'] << YamlFile.new(path, storage)
          elsif MIGRATIONS_REGEX.match?(path)
            hash['migrations'] ||= []
            hash['migrations'] << MigrationFile.new(path, storage)
          elsif /\.liquid$/i.match?(path)
            hash['to_be_removed'] ||= []
            hash['to_be_removed'] << LiquidFile.new(path, storage)
          end
        end
        hash
      end
    end

    def assets
      grouped_files['assets']
    end

    def liquid
      partials + pages + legacy_liquid + notifications
    end

    def yaml
      schema + translations
    end

    def schema
      grouped_files['schema'] || []
    end

    def translations
      grouped_files['translations'] || []
    end

    def partials
      grouped_files['partials'] || []
    end

    def notifications
      emails + smses + api_calls
    end

    def emails
      grouped_files['emails'] || []
    end

    def smses
      grouped_files['smes'] || []
    end

    def api_calls
      grouped_files['api_calls'] || []
    end

    def pages
      grouped_files['pages'] || []
    end

    def legacy_liquid
      grouped_files['to_be_removed'] || []
    end

    def directories
      storage.directories
    end

    def all
      @all ||= grouped_files.values.flatten
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
