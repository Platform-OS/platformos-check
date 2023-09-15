# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class ObjectCompletionProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @storage = make_in_memory_storage(
          "app/api_calls/send.liquid" => "",
          "app/lib/hello/my-function.liquid" => "",
        )
        @storage.files.each { |relative_path| @storage.stubs(:read).with(relative_path).returns('') }

        @provider = ObjectCompletionProvider.new(@storage)
        skip("Liquid-C not supported") if liquid_c_enabled?
      end

      def test_completions_from_different_cursor_positions
        # variables
        assert_can_complete(@provider, "{{ ")
        assert_can_complete(@provider, "{{ con")

        # Cursor inside the token
        assert_can_complete(@provider, "{{ con }}", -3)

        # filters
        assert_can_complete(@provider, "{{ '1234' | replace: con")

        # for loops
        assert_can_complete(@provider, "{% for p in con")
        assert_can_complete(@provider, "{% for p in con %}", -3)

        # case statements
        assert_can_complete(@provider, "{% case con")
        assert_can_complete(@provider, "{% when con")

        # render attributes
        assert_can_complete(@provider, "{% render 'snippet', products: con")

        # out of bounds for completions
        refute_can_complete(@provider, "{{")
        refute_can_complete(@provider, "{{ con ")
        refute_can_complete(@provider, "{{ con }")
        refute_can_complete(@provider, "{{ con }}")

        # not an object.
        refute_can_complete(@provider, "{{ all_products.")
        refute_can_complete(@provider, "{{ all_products. ")
        refute_can_complete(@provider, "{{ all_products.featured_image ")

        # not completable
        refute_can_complete(@provider, "{%  ")
        refute_can_complete(@provider, "{% rend")
      end

      def test_correctly_suggests_things
        assert_can_complete_with(@provider, "{{ ", 'context')
        assert_can_complete_with(@provider, "{{  ", 'context')
        assert_can_complete_with(@provider, "{{ con", 'context')

        object_not_in_source_index = 'customer_address'

        refute_can_complete_with(@provider, "{{ cust", object_not_in_source_index)
        refute_can_complete_with(@provider, "{{ all_", 'cart')
        refute_can_complete_with(@provider, "{{ curr", 'current_user')
        refute_can_complete_with(@provider, "{{ first_n", 'first_name')
      end

      def test_correctly_suggests_response_for_api_notification
        assert_can_complete_with(@provider, "{{ re", 'response', 0, nil, 'app/api_calls/send.liquid')
        refute_can_complete_with(@provider, "{{ re", 'response', 0, nil, 'app/lib/hello/my-function.liquid')
      end
    end
  end
end
