# frozen_string_literal: true

module PlatformosCheck
  class TranslationFile < YamlFile
    TRANSLATION_FILTERS = Set.new(%w[t t_escape translate translate_escape]).freeze

    def load!
      @storage.platformos_app.instance_variable_set(:@translations_hash, nil) unless @loaded
      super
      return if module_name.nil?

      language = @content.keys.first
      @content[language].transform_keys! { |key| key.start_with?(module_prefix) ? key : "#{module_prefix}#{key}" }
    end
  end
end
