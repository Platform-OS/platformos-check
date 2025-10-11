# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class TranslationFilesMatchTest < Minitest::Test
    def test_no_offense_when_identical
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                title: "Item"
        YML
        "app/translations/de/item.yml" => <<~YML
          de:
            app:
              item:
                title: "Item"
        YML
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_if_no_directory_in_module_but_file_name_is_a_language
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "modules/my_module/public/translations/en.yml" => <<~YML
          en:
            hello: "World"
        YML
      )

      assert_offenses("", offenses)
    end

    def test_reports_when_other_language_than_in_path
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/item.yml" => <<~YML
          de:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      )

      assert_offenses(<<~END, offenses)
        Mismatch detected - file inside en directory defines translations for `de` at app/translations/en/item.yml
      END
    end

    def test_corrects_other_language_than_in_path
      expected_sources = {
        "app/translations/en/item.yml" => <<~YML
          ---
          en:
            app:
              item:
                title: Item
                description: Item

        YML
      }
      sources = fix_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/item.yml" => <<~YML
          de:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      )

      refute_empty sources
      sources.each do |path, source|
        assert_equal(expected_sources[path], source)
      end
    end

    def test_corrects_if_file_in_not_language_directory
      expected_sources = {
        "app/translations/en/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      }
      sources = fix_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      )

      refute_empty sources
      sources.each do |path, source|
        assert_equal(expected_sources[path], source)
      end
    end

    def test_corrects_if_module_file_in_not_language_directory
      expected_sources = {
        "modules/my_module/public/translations/en/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      }
      sources = fix_platformos_app(
        TranslationFilesMatch.new,
        "modules/my_module/public/translations/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      )

      refute_empty sources
      sources.each do |path, source|
        assert_equal(expected_sources[path], source)
      end
    end

    def test_reports_when_there_is_no_default_language_file_equivalent
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/de/item.yml" => <<~YML
          de:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      )

      assert_offenses(<<~END, offenses)
        Mismatch detected - missing `app/translations/en/item.yml` to define translations the  default language at app/translations/de/item.yml
      END
    end

    def test_reports_when_there_is_no_file_for_other_language
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/base.yml" => <<~YML,
          en:
            app:
              hello: "World"
        YML
        "app/translations/de/base.yml" => <<~YML,
          de:
            app:
              hello: "World"
        YML
        "app/translations/en/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      )

      assert_offenses(<<~END, offenses)
        Mismatch detected - missing `app/translations/de/item.yml` file to define translations for `de` at app/translations/en/item.yml
      END
    end

    def test_corrects_missing_file_for_other_language
      expected_sources = {
        "app/translations/en/base.yml" => <<~YML,
          en:
            app:
              hello: "World"
        YML
        "app/translations/de/base.yml" => <<~YML,
          de:
            app:
              hello: "World"
        YML
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
        "app/translations/de/item.yml" => <<~YML
          ---
          de:
            app:
              item:
                title: Item
                description: Item
        YML
      }
      sources = fix_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/base.yml" => <<~YML,
          en:
            app:
              hello: "World"
        YML
        "app/translations/de/base.yml" => <<~YML,
          de:
            app:
              hello: "World"
        YML
        "app/translations/en/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      )

      refute_empty sources
      sources.each do |path, source|
        assert_equal(expected_sources[path], source)
      end
    end

    def test_reports_when_other_language_file_does_not_include_key_from_default
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
        "app/translations/de/item.yml" => <<~YML
          de:
            app:
              item:
                title: "Item"
        YML
      )

      assert_offenses(<<~END, offenses)
        Mismatch detected - structure differs from the default language file app/translations/en/item.yml at app/translations/de/item.yml
      END
    end

    def test_reports_when_other_language_file_includes_key_that_does_not_exist_in_default
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                title: "Item"
        YML
        "app/translations/de/item.yml" => <<~YML
          de:
            app:
              item:
                title: "Item"
                description: "Item"
        YML
      )

      assert_offenses(<<~END, offenses)
        Mismatch detected - structure differs from the default language file app/translations/en/item.yml at app/translations/de/item.yml
      END
    end

    def test_reports_when_other_language_file_has_string_and_default_hash
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                title: "Item"
        YML
        "app/translations/de/item.yml" => <<~YML
          de:
            app:
              item: "Item"
        YML
      )

      assert_offenses(<<~END, offenses)
        Mismatch detected - structure differs from the default language file app/translations/en/item.yml at app/translations/de/item.yml
      END
    end

    def test_reports_when_other_language_file_has_hash_and_default_string
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item: "Item"
        YML
        "app/translations/de/item.yml" => <<~YML
          de:
            app:
              item:
                title: "Item"
        YML
      )

      assert_offenses(<<~END, offenses)
        Mismatch detected - structure differs from the default language file app/translations/en/item.yml at app/translations/de/item.yml
      END
    end

    def test_no_offense_for_pluralization_differences
      offenses = analyze_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                one: Item
                other: Items
        YML
        "app/translations/es/item.yml" => <<~YML
          es:
            app:
              item:
                zero: Nada
                other: Item
        YML
      )

      assert_offenses("", offenses)
    end

    def test_corrects_different_structure_between_other_language_and_default_language
      expected_sources = {
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                title: "Item"
                description: "Item"
              hello:
              my_translation: "My translation"
            base: Base
        YML
        "app/translations/de/item.yml" => <<~YML
          ---
          de:
            app:
              item:
                title: Artikel
                description: Item
              hello:
                world: Welt
              my_translation:
                value: hello
            base: Base

        YML
      }
      sources = fix_platformos_app(
        TranslationFilesMatch.new,
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                title: "Item"
                description: "Item"
              hello:
              my_translation: "My translation"
            base: Base
        YML
        "app/translations/de/item.yml" => <<~YML
          de:
            app:
              item:
                title: "Artikel"
              hello:
                world: "Welt"
              my_translation:
                value: "hello"
        YML
      )

      refute_empty sources

      sources.each do |path, source|
        assert_equal(expected_sources[path], source)
      end
    end
  end
end
