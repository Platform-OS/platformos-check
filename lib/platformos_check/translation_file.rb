# frozen_string_literal: true

module PlatformosCheck
  class TranslationFile < YamlFile
    DIR_PREFIX = %r{\A/?((marketplace_builder|app)/(translations)/|(app/)?modules/((\w|-)*)/(private|public)/(translations)/)}
    TRANSLATION_FILTERS = Set.new(%w[t t_escape translate translate_escape]).freeze
    attr_reader :language

    def load!
      before_load
      super
      after_load
    end

    def before_load
      @storage.platformos_app.instance_variable_set(:@translations_hash, nil) unless @loaded
    end

    def after_load
      @language = @content&.keys&.first
      return if module_name.nil?

      @content[@language].transform_keys! { |key| key.start_with?(module_prefix) ? key : "#{module_prefix}#{key}" }
    end

    def language_from_path
      @language_from_path ||= begin
        name_without_prefix_components = name.sub(module_prefix, '').split(File::SEPARATOR)
        name_without_prefix_components.size > 1 ? name_without_prefix_components.first : nil
      end
    end

    def update_contents(new_content = {})
      before_load
      super(new_content)
      @loaded = true

      after_load
    end

    def dir_prefix
      DIR_PREFIX
    end

    def translation?
      true
    end

    def rewriter
      @rewriter ||= AppFileRewriter.new(@relative_path, source)
    end
  end
end
