# frozen_string_literal: true

module PlatformosCheck
  class TranslationFile < YamlFile
    DIR_PREFIX = %r{\A/?((marketplace_builder|app)/(translations)/|modules/((\w|-)*)/(private|public)/(translations)/)}
    TRANSLATION_FILTERS = Set.new(%w[t t_escape translate translate_escape]).freeze
    attr_reader :language

    def load!
      @storage.platformos_app.instance_variable_set(:@translations_hash, nil) unless @loaded
      super
      @language = @content&.keys&.first
      return if module_name.nil?

      @content[@language].transform_keys! { |key| key.start_with?(module_prefix) ? key : "#{module_prefix}#{key}" }
    end

    def dir_prefix
      DIR_PREFIX
    end

    def language_from_path
      @language_from_path ||= name.sub(module_prefix, '').split(File::SEPARATOR).first
    end

    def translation?
      true
    end
  end
end
