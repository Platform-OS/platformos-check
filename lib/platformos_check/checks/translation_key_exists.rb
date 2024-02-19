# frozen_string_literal: true

module PlatformosCheck
  # Recommends using {% liquid ... %} if 5 or more consecutive {% ... %} are found.
  class TranslationKeyExists < LiquidCheck
    severity :error
    categories :translation, :liquid
    doc docs_url(__FILE__)

    def on_variable(node)
      return unless node.value.name.is_a?(String)
      return unless node.filters.size == 1

      translation_filter = node.filters.detect { |f| TranslationFile::TRANSLATION_FILTERS.include?(f[0]) }
      return unless translation_filter
      return unless translation_filter

      filter_attributes = translation_filter[2] || {}

      return unless filter_attributes['default'].nil?
      return if !filter_attributes['scope'].nil? && !filter_attributes['scope'].is_a?(String)

      lang = filter_attributes['language'].is_a?(String) ? filter_attributes['language'] : @platformos_app.default_language
      translation_components = node.value.name.split('.')

      translation_components = filter_attributes['scope'].split('.') + translation_components if filter_attributes['scope']

      return add_translation_offense(node:, lang:) if @platformos_app.translations_hash.empty?

      hash = @platformos_app.translations_hash[lang] || {}
      index = 0
      while translation_components[index]
        hash = hash[translation_components[index]]
        if hash.nil?
          add_translation_offense(node:, lang:)
          break
        end
        index += 1
      end
    end

    protected

    def add_translation_offense(node:, lang:)
      add_offense("Translation `#{lang}.#{node.value.name}` does not exists", node:)
    end
  end
end
