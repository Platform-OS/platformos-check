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

    def test_reports_key_does_not_exist
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
        Translation `app.item.undefined` does not exists at app/views/pages/index.liquid:1
      END
    end
  end
end
