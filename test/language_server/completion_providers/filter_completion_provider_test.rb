# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class FilterCompletionProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      FILTER_WITH_INPUT_TYPE_VARIABLE = 'default'

      def setup
        @provider = FilterCompletionProvider.new
        @filter_compatible_with = {
          array: 'array_sort_by',
          string: 'url_decode',
          number: 'floor'
          # form: 'currency_selector',
          # metafield: 'metafield_tag',
          # address: 'format_address',
          # paginate: 'default_pagination',
          # media: 'external_video_url',
          # font: 'font_url'
        }
      end

      def test_can_complete?
        assert_can_complete(@provider, "{{ 'foo.js' | ")
        assert_can_complete(@provider, "{{ 'foo.js' | asset")
        assert_can_complete(@provider, "{{ 'foo.js' | asset_url | ")
        assert_can_complete(@provider, "{{ 'foo.js' | asset_url | downcase")

        refute_can_complete(@provider, "{{ 'foo.js' ")
        refute_can_complete(@provider, "{% if foo")
      end

      def test_completions
        assert_can_complete_with(@provider, "{{ 'an object' | ", "type_of")
        assert_can_complete_with(@provider, "{{ 'foo.js' | ", "capitalize")
        assert_can_complete_with(@provider, "{{ 'foo.js' | asset", "asset_url")
        assert_can_complete_with(@provider, "{{ 'foo.js' | asset_url | url", "url_decode")
      end

      def test_completions_with_content_after_cursor
        offset = -2

        assert_can_only_complete_with("{{ 28 | }}", 'number', offset)
        assert_can_only_complete_with("{{ 'test%40test.com' | }}", 'string', offset)
        assert_can_only_complete_with("{% assign tp = context.instance.id %}\n{{ tp | }}", 'number', offset)
      end

      def test_filters_compatible_with_the_array_type
        skip('do not know how to get array object')
        input_type = 'array'

        assert_can_only_complete_with("{% assign ct = '' | split | ", input_type)
        assert_can_only_complete_with("{% assign c = product.collections | ", input_type)
        assert_can_only_complete_with("{{ current_tags | ", input_type)
        assert_can_only_complete_with("{{ product.collections | ", input_type)
        assert_can_only_complete_with("{% assign ct = current_tags %}\n{{ ct | ", input_type)
        assert_can_only_complete_with("{{ blog.metafields | ", input_type)
      end

      def test_filters_compatible_with_the_string_type
        input_type = 'string'

        assert_can_only_complete_with("{% assign t = context.authenticity_token | ", input_type)
        assert_can_only_complete_with("{{ content_for_layout | ", input_type)
        assert_can_only_complete_with("{% assign t = context.authenticity_token %}\n{{ t | ", input_type)
        assert_can_only_complete_with("{{ 'test%40test.com' | ", input_type)
        assert_can_only_complete_with("{{ '' | ", input_type)
        skip('do not know how to get array object')

        assert_can_only_complete_with("{% for tag in collection.all_tags %}\n{%- if current_tags contains tag -%}\n{{ tag | ", input_type)
      end

      def test_filters_compatible_with_the_string_type_and_assignment_and_attribute
        input_type = 'string'
        token = "{%- assign user = context.current_user -%}\n{{ user.first_name | "

        assert_can_only_complete_with(token, input_type)
      end

      def test_filters_compatible_with_the_string_type_and_multi_level_assignments_and_attributes
        input_type = 'string'
        token = "{%- assign my_products = '[{\"url\": \"foo\"}]' | parse_json -%}{%- assign my_product = my_products.first -%}\n{{ my_product.url | "

        assert_can_only_complete_with(token, input_type)
      end

      def test_filters_compatible_with_the_string_type_and_assignment_in_same_line
        input_type = 'string'

        assert_can_only_complete_with("{% assign secret_potion = 'Polyjuice' | ", input_type)
      end

      def test_filters_compatible_with_the_string_type_and_assignment_and_variable_in_next_line
        input_type = 'string'
        token = "{%- assign text = '  Some potions create whitespace.      ' -%}\n{{ text | "

        assert_can_only_complete_with(token, input_type)
      end

      def test_filters_incompatible_with_already_escaped_string
        skip('do not have object with denied_filters')

        refute_can_complete_with(@provider, "{{ page_description | ", "escape")
      end

      def test_filters_compatible_with_the_number_type
        input_type = 'number'

        assert_can_only_complete_with("{{ context.instance.id | ", input_type)
        assert_can_only_complete_with("{% assign tp = context.instance.id %}\n{{ tp | ", input_type)
        assert_can_only_complete_with("{{ -4.2 | ", input_type)
      end

      def test_filters_compatible_with_the_number_type_and_assignment_in_same_line
        input_type = 'number'

        assert_can_only_complete_with("{% assign secret_potion = 2 | ", input_type)
      end

      def test_filters_compatible_with_the_form_type
        skip('form type not supported')
        input_type = 'form'

        assert_can_only_complete_with("{{ form | ", input_type)
      end

      def test_filters_compatible_with_the_font_type
        skip('font type not supported')
        input_type = 'font'

        assert_can_only_complete_with("{{ font.variants.first | ", input_type)
      end

      def test_filters_compatible_with_the_variable_type
        assert_can_complete_with(@provider, "{{ product | ", FILTER_WITH_INPUT_TYPE_VARIABLE)
        token = "{{ context.current_user.email | "

        assert_can_complete_with(@provider, token, FILTER_WITH_INPUT_TYPE_VARIABLE)
        assert_can_only_complete_with(token, 'string')
      end

      def test_filters_compatible_with_the_variable_type_and_assignment
        token = "{%- assign display_price = false -%}\n{{ display_price | "

        assert_can_complete_with(@provider, token, FILTER_WITH_INPUT_TYPE_VARIABLE)
      end

      def test_filters_compatible_with_the_media_type
        skip('media type not supported')
        input_type = 'media'

        assert_can_only_complete_with("{{ product.featured_media | ", input_type)
        assert_can_only_complete_with("{% for media in product.media %}
  {% if media.media_type == 'external_video' %}
    {% if media.host == 'youtube' %}
      {{ media | ", input_type)
      end

      def test_filters_compatible_with_the_metafield_type
        skip("platformos_app-liquid-docs changes causing test to fail")

        assert_can_only_complete_with("{{ shop.metafields | ", 'metafield')
      end

      def test_filters_compatible_with_the_paginate_type
        skip('paginate type not supported')

        assert_can_only_complete_with("{{- paginate | ", 'paginate')
      end

      def test_filters_compatible_with_the_address_type
        skip('address type not supported')

        assert_can_only_complete_with("{{ shop.address | ", 'address')
      end

      def test_suggest_all_filters_when_types_incompatible
        [
          "{{ article.image | ", # return_type "image", but no filter with corresponding input type
          "{{ product.metafields.information.seasonal | ", # product.metafields has return_type "untyped"
          "{{ product | ", # return_type array is empty
          "{{ settings.type_header_font | " # return_type and properties arrays are empty
        ].each do |token|
          @filter_compatible_with.each do |_, filter_name|
            assert_can_complete_with(@provider, token, filter_name)
          end
          assert_can_complete_with(@provider, token, FILTER_WITH_INPUT_TYPE_VARIABLE)
        end
      end

      def test_complete_deprecated_filters
        deprecated_filter = "hash_fetch"

        assert_can_complete_with(@provider, "{{ 'foo.js' | hash_fet", deprecated_filter)
        assert_can_complete_with(@provider, "{% assign t = product.title | ", deprecated_filter)
      end

      private

      def assert_can_only_complete_with(token, input_type_to_be_tested, offset = 0)
        @filter_compatible_with.each do |input_type, filter_name|
          if input_type.to_s == input_type_to_be_tested
            assert_can_complete_with(@provider, token, filter_name, offset)
          else
            refute_can_complete_with(@provider, token, filter_name, offset)
          end
        end
      rescue StandardError => e
        puts "Error\n#{e}\nwas thrown for token\n#{token}"
        raise e
      end
    end
  end
end
