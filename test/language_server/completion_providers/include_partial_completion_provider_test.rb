# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class IncludePartialCompletionProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @storage = make_in_memory_storage(
          "app/lib/hello/my-function.liquid" => "",
          "app/views/partials/hello/multiple/level/my_html.liquid" => "",
          "app/graphql/hello/my_query.graphql" => "",
          "modules/my-module/public/views/partials/hello/my_html.liquid" => ""
        )
        @storage.files.each { |relative_path| @storage.stubs(:read).with(relative_path).returns('') }
        @provider = IncludePartialCompletionProvider.new(@storage)
      end

      def test_suggests_existing_partials_in_any_dir_for_include
        markup = '{% include "hello", arg: 10 %}'

        assert_can_complete_with(@provider, markup, "hello/my-function", -17, 0)
        assert_can_complete_with(@provider, markup, "hello/multiple/level/my_html", -17, 0)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/my_query", -17, 0)

        markup = '{% include "modules/", arg: 10 %}'

        refute_can_complete_with(@provider, markup, "hello/my-function", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/multiple/level/my_html", -17, 0)
        assert_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/my_query", -17, 0)
      end
    end
  end
end
