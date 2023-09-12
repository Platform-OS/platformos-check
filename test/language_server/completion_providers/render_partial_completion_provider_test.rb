# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class RenderPartialCompletionProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @storage = make_in_memory_storage(
          "app/lib/hello/my-function.liquid" => "",
          "app/views/partials/hello/multiple/level/my_html.liquid" => "",
          "app/graphql/hello/my_query.graphql" => "",
          "modules/my-module/public/views/partials/hello/my_html.liquid" => ""
        )
        @provider = RenderPartialCompletionProvider.new(@storage)
      end

      def test_suggests_existing_partials_in_any_dir_for_render
        markup = '{% render "hello", arg: 10 %}'

        assert_can_complete_with(@provider, markup, "hello/my-function", -17)
        assert_can_complete_with(@provider, markup, "hello/multiple/level/my_html", -17)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -17)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -17)
        refute_can_complete_with(@provider, markup, "hello/my_query", -17)

        markup = '{% render "modules/", arg: 10 %}'

        refute_can_complete_with(@provider, markup, "hello/my-function", -17)
        refute_can_complete_with(@provider, markup, "hello/multiple/level/my_html", -17)
        assert_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -17)
        refute_can_complete_with(@provider, markup, "hello/my_query", -17)
      end
    end
  end
end
