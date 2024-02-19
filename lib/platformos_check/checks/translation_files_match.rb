# frozen_string_literal: true

module PlatformosCheck
  class TranslationFilesMatch < YamlCheck
    severity :error
    category :translation
    doc docs_url(__FILE__)

    PLURALIZATION_KEYS = Set.new(%w[zero one two few many other])

    def on_file(file)
      return unless file.translation?
      return if file.parse_error
      return add_offense_wrong_language_in_file(file) if file.language != file.language_from_path
      return check_if_file_exists_for_all_other_languages(file) if file.language == @platformos_app.default_language

      default_language_file = @platformos_app.grouped_files[PlatformosCheck::TranslationFile][file.name.sub(file.language, @platformos_app.default_language)]

      return add_offense_missing_file(file) if default_language_file.nil?

      add_offense_different_structure(file, default_language_file) unless same_structure?(default_language_file.content[@platformos_app.default_language], file.content[file.language])
    end

    protected

    def add_offense_wrong_language_in_file(file)
      add_offense("Mismatch detected - file inside #{file.language_from_path} directory defines translations for `#{file.language}`", app_file: file) do |_corrector|
        file.update_contents(file.content[file.language_from_path] = file.content.delete(file.content[file.language]))
        file.write
      end
    end

    def add_offense_missing_file(file)
      add_offense("Mismatch detected - missing `#{file.relative_path.to_s.sub(file.language, @platformos_app.default_language)}` to define translations the  default language", app_file: file)
    end

    def check_if_file_exists_for_all_other_languages(file)
      @platformos_app.translations_hash.each_key do |lang|
        next if lang == @platformos_app.default_language

        language_file = @platformos_app.grouped_files[PlatformosCheck::TranslationFile][file.name.sub(file.language, lang)]
        add_offense_missing_translation_file(file, lang) if language_file.nil?
      end
    end

    def add_offense_missing_translation_file(file, lang)
      missing_file_path = file.relative_path.to_s.sub(file.language, lang)
      add_offense("Mismatch detected - missing `#{missing_file_path}` file to define translations for `#{lang}`", app_file: file) do |corrector|
        missing_file_content = file.content.clone
        missing_file_content[lang] = missing_file_content.delete(file.language)
        corrector.create_file(@platformos_app.storage, missing_file_path, YAML.dump(missing_file_content))
      end
    end

    def same_structure?(hash1, hash2)
      if !hash1.is_a?(Hash) && !hash2.is_a?(Hash)
        true
      elsif (hash1.is_a?(Hash) && !hash2.is_a?(Hash)) || (!hash1.is_a?(Hash) && hash2.is_a?(Hash))
        false
      elsif pluralization?(hash1) && pluralization?(hash2)
        true
      elsif hash1.keys.map(&:to_s).sort != hash2.keys.map(&:to_s).sort
        false
      else
        hash1.keys.all? { |key| same_structure?(hash1[key], hash2[key]) }
      end
    end

    def add_offense_different_structure(file, default_language_file)
      add_offense("Mismatch detected - structure differs from the default language file #{default_language_file.relative_path}", app_file: file) do |_corrector|
        file.content[file.language].transform_values! { |v| v.nil? ? {} : v }
        file.content[file.language] = default_language_file.content[default_language_file.language].deep_merge(file.content[file.language])
        file.write
      end
    end

    def pluralization?(hash)
      hash.all? do |key, value|
        PLURALIZATION_KEYS.include?(key) && !value.is_a?(Hash)
      end
    end
  end
end
