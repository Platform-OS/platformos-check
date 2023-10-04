# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class ObjectAttributeCompletionProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @storage = make_in_memory_storage(
          "app/graphql/users/find.graphql" => '
            query {
              records{
                total_entries
                total_pages
                has_previous_page
                has_next_page
                results {
                  id
                  key: property(name: "key")
                }
              }
            }',
          "app/graphql/users/find_with_fragment.graphql" => '
            fragment UserFields on User {
              id
              email
              first_name: property(name: "first_name")
              last_name: property(name: "last_name")
              slug: property(name: "slug")
            }

            query get{
              records {
                results {
                  id
                  ...UserFields
                }
              }
            }',
          "app/lib/find_user.liquid" => '
            {% liquid
              return context.current_user
            %}',
          "app/lib/find_context.liquid" => '
            {% liquid
              return context
            %}',
          "app/lib/find_user_in_graphql.liquid" => '
            {% liquid
              graphql g = "users/find"
              return g
            %}',
        )
        @storage.files_with_content.each { |relative_path, content| @storage.stubs(:read).with(relative_path).returns(content) }

        @provider = ObjectAttributeCompletionProvider.new(@storage)
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

      def test_completions_when_it_completes_graphql_variable
        assert_can_complete_with(@provider, '{% graphql g = "users/find" %}{{ g.', 'records')
        assert_can_complete_with(@provider, '{% graphql g = "users/find" %}{{ g.records.', 'total_entries')
        assert_can_complete_with(@provider, '{% graphql g = "users/find" %}{{ g.records.results', 'key')
      end

      def test_completions_when_it_completes_graphql_variable_with_fragment
        assert_can_complete_with(@provider, '{% graphql g = "users/find_with_fragment" %}{{ g.records.results', 'id')
        assert_can_complete_with(@provider, '{% graphql g = "users/find_with_fragment" %}{{ g.records.results', 'slug')
      end

      def test_completions_when_it_completes_graphql_inside_liquid_tag
        assert_can_complete_with(
          @provider, '{% liquid
  graphql g = "users/find"
  g.
%}',
          'records', 0, 2, nil, 3)

        assert_can_complete_with(
          @provider, '{%liquid
  graphql gresult = "users/find"
  gresult.
%}',
          'records', 0, 2, nil, 9)

        assert_can_complete_with(
          @provider, '{% liquid
  graphql g = "users/find"
  assign r = g.
%}',
          'records', 0, 2, nil, 14)

        assert_can_complete_with(
          @provider, '{% liquid
  graphql g = "users/find"
  function r = "call_me_maybe", foo: g.
%}',
          'records', 0, 2, nil, 38)

        assert_can_complete_with(
          @provider, '{% liquid
  graphql x = "users/find", id: user_id
  x.
%}',
          'records', 0, 2, nil, 3)

        assert_can_complete_with(
          @provider, '{% liquid
  graphql g = "users/find"
  return g.
%}',
          'records', 0, 2, nil, 10)

        assert_can_complete_with(
          @provider, '{% liquid
  graphql g = "users/find"
  log g.
%}',
          'records', 0, 2, nil, 10)

        assert_can_complete_with(
          @provider, '{% liquid
  hash_assign foo["bar"] = "zoo"
  graphql g = "users/find"
  return g.
%}',
          'records', 0, 3, nil, 10)

        skip('fix it')
        assert_can_complete_with(
          @provider, '{% liquid
  if true
    graphql g = "users/find"
  endif
  return g.
%}',
          'records', 0, 4, nil, 10)
      end


      def test_completions_function_result_inside_liquid_tag
        assert_can_complete_with(
          @provider, '{% liquid
  function r = "find_user", id: 1
  r.
%}',
          'first_name', 0, 2, nil, 3)

        assert_can_complete_with(
          @provider, '{% liquid
  assign r = context
  assign x = r.current_user.
%}',
          'first_name', 0, 2, nil, 27)

        assert_can_complete_with(
          @provider, '{% liquid
  function r = "find_context", id: 1
  r.current_user.
%}',
          'first_name', 0, 2, nil, 16)

        assert_can_complete_with(
          @provider, '{% liquid
  function r = "find_user_in_graphql", id: 1
  r.
%}',
          'records', 0, 2, nil, 3)

        assert_can_complete_with(
          @provider, '{% liquid
  function r = "find_user_in_graphql", id: 1
  r.records.
%}',
          'results', 0, 2, nil, 11)
      end
    end
  end
end
