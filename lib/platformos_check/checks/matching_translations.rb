# frozen_string_literal: true

module PlatformosCheck
  class MatchingTranslations < JsonCheck
    severity :suggestion
    category :translation
    doc docs_url(__FILE__)

    def initialize
      @files = []
    end

    def on_file(file)
      return unless file.name.start_with?("locales/")
      return unless file.content.is_a?(Hash)
      return if /\.schema$/.match?(file.name)
      return if file.name == @platformos_app.default_locale_json&.name

      @files << file
    end

    def on_end
      return unless @platformos_app.default_locale_json&.content

      @files.each do |file|
        diff = LocaleDiff.new(@platformos_app.default_locale_json.content, file.content)
        diff.add_as_offenses(self, platformos_app_file: file)
      end
    end
  end
end
