# frozen_string_literal: true

module PlatformosCheck
  class TranslationFile < YamlFile
    def load!
      super
      return if module_name.nil?

      language = @content.keys.first
      @content[language].transform_keys! { |key| key.start_with?(module_prefix) ? key : "#{module_prefix}#{key}" }
    end
  end
end
