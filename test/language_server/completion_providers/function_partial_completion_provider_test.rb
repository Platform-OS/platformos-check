# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class FunctionPartialCompletionProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @storage = make_in_memory_storage(
          "app/lib/hello/my-function.liquid" => "",
          "app/views/partials/hello/multiple/level/my_html.liquid" => "",
          "app/graphql/hello/my_query.graphql" => "",
          "modules/my-module/public/views/partials/hello/my_html.liquid" => ""
        )
        @storage.files.each { |relative_path| @storage.stubs(:read).with(relative_path).returns('') }
        @provider = FunctionPartialCompletionProvider.new(@storage)
      end

      def test_suggests_existing_partials_in_any_dir_for_function
        markup = '{% function res = "hello", arg: 10 %}'

        assert_can_complete_with(@provider, markup, "hello/my-function", -17, 0)
        assert_can_complete_with(@provider, markup, "hello/multiple/level/my_html", -17, 0)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/my_query", -17, 0)

        refute_can_complete_with(@provider, markup, "hello/my-function", -26, 0)
        refute_can_complete_with(@provider, markup, "hello/multiple/level/my_html", -26, 0)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -26, 0)
        refute_can_complete_with(@provider, markup, "hello/my_query", -26, 0)

        markup = '{% function res = "modules/", arg: 10 %}'

        refute_can_complete_with(@provider, markup, "hello/my-function", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/multiple/level/my_html", -17, 0)
        assert_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/my_query", -17, 0)
      end

      def test_suggests_existing_partials_from_the_middle
        markup = '{% function res = "hello/multiple/level/my_html", arg: 10 %}'

        assert_can_complete_with(@provider, markup, "hello/my-function", -36, 0)
        assert_can_complete_with(@provider, markup, "hello/multiple/level/my_html", -36, 0)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -36, 0)
        refute_can_complete_with(@provider, markup, "hello/my_query", -36, 0)
      end

      def test_suggests_existing_partials_for_second_function
        markup = <<~END
          {% liquid
            function res = "somevalue"
            function res = "hello", arg: 10
          %}
        END

        assert_can_complete_with(@provider, markup, "hello/my-function", -13, 2)
        assert_can_complete_with(@provider, markup, "hello/multiple/level/my_html", -13, 2)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -13, 2)
      end
    end
  end
end
