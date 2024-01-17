# frozen_string_literal: true

module PlatformosCheck
  # Recommends using {% liquid ... %} if 5 or more consecutive {% ... %} are found.
  class TranslationKeyExists < LiquidCheck
    severity :suggestion
    category :liquid
    doc docs_url(__FILE__)

    def initialize; end

    def on_variable(node)
      return unless node.value.name.is_a?(String)

      translation_filter = node.filters.detect { |f| TranslationFile::TRANSLATION_FILTERS.include?(f[0]) }
      return unless translation_filter
      return unless translation_filter

      filter_attributes = translation_filter[2] || {}

      return unless filter_attributes['default'].nil?

      translation_components = node.value.name.split('.')
      translation_components = filter_attributes['scope'].split('.') + translation_components if filter_attributes['scope']

      return add_offense("Translation `#{node.value.name}` does not exists", node:) if @platformos_app.translations_hash.empty?

      @platformos_app.translations_hash.keys.each do |lang|
        hash = @platformos_app.translations_hash[@platformos_app.default_language]
        if hash
          while (key = translation_components.shift)
            hash = hash[key]
            if hash.nil?
              @not_found = true
              break
            end
          end
        else
          @not_found = true
        end

        add_offense("Translation `#{node.value.name}` does not exists", node:) if @not_found
      end
    end
  end
end
