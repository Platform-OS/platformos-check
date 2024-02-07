# frozen_string_literal: true

module PlatformosCheck
  class TranslationFilesMatch < YamlCheck
    severity :error
    category :translation
    doc docs_url(__FILE__)

    def on_file(file)
      return unless file.translation?
      return if file.parse_error
      return add_offense("Mismatch detected - file inside #{file.language_from_path} directory defines translations for `#{file.language}`", app_file: file) if file.language != file.language_from_path
      return check_if_file_exists_for_all_other_languages(file) if file.language == @platformos_app.default_language

      default_language_file = @platformos_app.grouped_files[PlatformosCheck::TranslationFile][file.name.sub(file.language, @platformos_app.default_language)]

      return add_offense("Mismatch detected - missing `#{file.relative_path.to_s.sub(file.language, @platformos_app.default_language)}` to define translations the  default language", app_file: file) if default_language_file.nil?

      add_offense("Mismatch detected - structure differs from the default language file #{default_language_file.relative_path}", app_file: file) unless same_structure?(default_language_file.content[@platformos_app.default_language], file.content[file.language])
    end

    protected

    def check_if_file_exists_for_all_other_languages(file)
      @platformos_app.translations_hash.keys.each do |lang|
        next if lang == @platformos_app.default_language

        language_file = @platformos_app.grouped_files[PlatformosCheck::TranslationFile][file.name.sub(file.language, lang)]
        add_offense("Mismatch detected - missing `#{file.relative_path.to_s.sub(file.language, lang)}` file to define translations for `#{lang}`", app_file: file) if language_file.nil?
      end
    end

    def same_structure?(hash1, hash2)
      if !hash1.is_a?(Hash) && !hash2.is_a?(Hash)
        true
      elsif (hash1.is_a?(Hash) && !hash2.is_a?(Hash)) || (!hash1.is_a?(Hash) && hash2.is_a?(Hash))
        false
      elsif hash1.keys.map(&:to_s).sort != hash2.keys.map(&:to_s).sort
        false
      else
        hash1.keys.all? { |key| same_structure?(hash1[key], hash2[key]) }
      end
    end
  end
end
