# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class ObjectAttributeCompletionProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @provider = ObjectAttributeCompletionProvider.new
      end

      def test_completions_when_it_completes_variable_lookups
        assert_can_complete_with(@provider, '{{ context.', 'authenticity_token')
        assert_can_complete_with(@provider, '{{- context.', 'authenticity_token')
        assert_can_complete_with(@provider, '{{ context.curren', 'current_user')
        assert_can_complete_with(@provider, "{{ context['curren", 'current_user')
        assert_can_complete_with(@provider, "{{ context['curren'", 'current_user', -1)
        assert_can_complete_with(@provider, '{{ context["curren"]', 'current_user', -2)
        assert_can_complete_with(@provider, '{{ context. }}', 'authenticity_token', -3)
      end

      def test_completions_when_it_completes_filter_arguments
        skip('dont have array in context yet')

        assert_can_complete_with(@provider, '{{ 0 | plus: current_tags.si', 'size')
        assert_can_complete_with(@provider, "{{ 0 | plus: current_tags['", 'size', -2)
        assert_can_complete_with(@provider, "{{ 0 | plus: current_tags['']", 'size', -2)
        assert_can_complete_with(@provider, "{{ 0 | plus: current_tags[\"", 'size', -2)
      end

      def test_completions_when_it_completes_filter_hash_arguments
        skip('dont have array in context yet')

        assert_can_complete_with(@provider, "{{ 0 | plus: bogus: current_tags.si", 'size')
      end

      def test_completions_when_it_completes_tag_arguments
        assert_can_complete_with(@provider, "{% if context.", 'current_user')
        assert_can_complete_with(@provider, "{%- if context.", 'current_user')
      end

      def test_completions_when_it_completes_array_types
        skip('dont have array in context yet')

        assert_can_complete_with(@provider, "{{ articles.first.", 'comments')
        assert_can_complete_with(@provider, "{{ product.images.first.", 'alt')
      end

      def test_completions_when_it_completes_nested_attributes
        assert_can_complete_with(@provider, '{{ context.current_user.', 'first_name')
        assert_can_complete_with(@provider, '{{ context.current_user.first_name', 'size')
        assert_can_complete_with(@provider, '{{ context.current_user.first_name.', 'size')
      end

      def test_completions_when_it_should_not_complete_non_attributes
        refute_can_complete(@provider, '{{ pro')
        refute_can_complete(@provider, '{% rend')
        refute_can_complete(@provider, "{% render '")
        refute_can_complete(@provider, 'some text')
      end

      def test_completions_when_it_has_multiple_dots
        refute_can_complete(@provider, '{{ cart..')
      end
    end
  end
end
