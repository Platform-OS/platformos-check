# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class GraphqlPartialCompletionProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @storage = make_storage(
          "app/graphql/hello/my-function.graphql" => "",
          "app/graphql/hello/my_html.graphql" => "",
          "app/lib/hello/my-lib.liquid" => "",
          "app/views/partials/hello/my-html-partial.liquid" => "",
          "modules/my-module/public/graphql/hello/my_html.graphql" => ""
        )
        @storage.files.each { |relative_path| @storage.stubs(:read).with(relative_path).returns('') }
        @provider = GraphqlPartialCompletionProvider.new(@storage)
      end

      def test_suggests_existing_graphql_files
        markup = '{% graphql res = "hello", arg: 10 %}'

        assert_can_complete_with(@provider, markup, "hello/my-function", -17, 0)
        assert_can_complete_with(@provider, markup, "hello/my_html", -17, 0)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/my-lib", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/my-html-partial", -17, 0)

        markup = '{% graphql res = "modules/", arg: 10 %}'

        refute_can_complete_with(@provider, markup, "hello/my-function", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/my_html", -17, 0)
        assert_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/my-lib", -17, 0)
        refute_can_complete_with(@provider, markup, "hello/my-html-partial", -17, 0)
      end

      def test_suggests_existing_graphql_files_for_liquid_block_with_function_not_confused
        markup = <<~END
          {% liquid
            function res = "hello"
            graphql res = "hello", arg: 10
          %}
        END

        assert_can_complete_with(@provider, markup, "hello/my-function", -13, 2)
        assert_can_complete_with(@provider, markup, "hello/my_html", -13, 2)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -13, 2)
        refute_can_complete_with(@provider, markup, "hello/my-lib", -13, 2)
        refute_can_complete_with(@provider, markup, "hello/my-html-partial", -13, 2)
      end

      def test_not_suggests_existing_graphql_files_for_argument
        markup = '{% graphql res = "hello", arg: "hello/" %}'

        refute_can_complete_with(@provider, markup, "hello/my-function", -7, 0)
        refute_can_complete_with(@provider, markup, "hello/my_html", -7, 0)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -7, 0)

        markup = "{% liquid\ngraphql res = 'hello', arg: 'hello/'\n%}"

        refute_can_complete_with(@provider, markup, "hello/my-function", -7, 0)
        refute_can_complete_with(@provider, markup, "hello/my_html", -7, 0)
        refute_can_complete_with(@provider, markup, "modules/my-module/hello/my_html", -7, 0)
      end
    end
  end
end
