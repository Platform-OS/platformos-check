# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class TranslationKeyExistsTest < Minitest::Test
    def test_no_offense_when_defined
      offenses = analyze_platformos_app(
        TranslationKeyExists.new,
        "app/views/pages/index.liquid" => <<~END,
          {{ 'app.item.title' | t }}
        END
        "app/translations/en/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
        YML
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_when_variable_used
      offenses = analyze_platformos_app(
        TranslationKeyExists.new,
        "app/views/pages/index.liquid" => <<~END,
          {% assign x = 'some.key' %}
          {{ x | t }}
        END
        "app/translations/en/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
        YML
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_when_defined_and_scope_is_used
      offenses = analyze_platformos_app(
        TranslationKeyExists.new,
        "app/views/pages/index.liquid" => <<~END,
          {{ 'title' | t: scope: 'app.item' }}
        END
        "app/translations/en/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
        YML
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_when_scope_variable_used
      offenses = analyze_platformos_app(
        TranslationKeyExists.new,
        "app/views/pages/index.liquid" => <<~END,
          {% assign var = 'my_scope' %}
          {{ 'title' | t: scope: var }}
        END
        "app/translations/en/item.yml" => <<~YML
          en:
            app:
        YML
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_when_default_option_used
      offenses = analyze_platformos_app(
        TranslationKeyExists.new,
        "app/views/pages/index.liquid" => <<~END,
          {{ 'app.item.undefined' | t: default: "Hello" }}
        END
        "app/translations/en/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
        YML
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_when_key_built_with_other_filters
      offenses = analyze_platformos_app(
        TranslationKeyExists.new,
        "app/views/pages/index.liquid" => <<~END,
          {% assign var = "undefined" %}
          {{ 'app.item.' | append: var | t }}
        END
        "app/translations/en/item.yml" => <<~YML
          en:
        YML
      )

      assert_offenses("", offenses)
    end

    def test_reports_key_does_not_exist_for_en
      offenses = analyze_platformos_app(
        TranslationKeyExists.new,
        "app/views/pages/index.liquid" => <<~END,
          {{ 'app.item.undefined' | t }}
        END
        "app/translations/en/item.yml" => <<~YML
          en:
            app:
              item:
                title: "Item"
        YML
      )

      assert_offenses(<<~END, offenses)
        Translation `en.app.item.undefined` does not exists at app/views/pages/index.liquid:1
      END
    end

    def test_no_offene_if_key_does_not_exist_for_non_default_langauge
      offenses = analyze_platformos_app(
        TranslationKeyExists.new,
        "app/views/pages/index.liquid" => <<~END,
          {{ 'app.item.title' | t: language: lang }}
        END
        "app/translations/en/__base.yml" => <<~YML,
          en:
            app:
              hello: "world"
        YML
        "app/translations/de/__base.yml" => <<~YML,
          de:
            app:
              hello: "world"
        YML
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                title: "Item"
                description: "Desc"
        YML
        "app/translations/de/item.yml" => <<~YML
          de:
            app:
              item:
                description: "Desc"
        YML
      )

      assert_offenses("", offenses)
    end

    def test_reports_key_does_not_exist_for_language_explicitly_set
      offenses = analyze_platformos_app(
        TranslationKeyExists.new,
        "app/views/pages/index.liquid" => <<~END,
          {{ 'app.item.title' | t: language: 'de' }}
        END
        "app/translations/en/__base.yml" => <<~YML,
          en:
            app:
              hello: "world"
        YML
        "app/translations/de/__base.yml" => <<~YML,
          de:
            app:
              hello: "world"
        YML
        "app/translations/en/item.yml" => <<~YML,
          en:
            app:
              item:
                title: "Item"
                description: "Desc"
        YML
        "app/translations/de/item.yml" => <<~YML
          de:
            app:
              item:
                description: "Desc"
        YML
      )

      assert_offenses(<<~END, offenses)
        Translation `de.app.item.title` does not exists at app/views/pages/index.liquid:1
      END
    end
  end
end
