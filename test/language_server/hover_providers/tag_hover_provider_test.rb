# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class TagHoverProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @provider = TagHoverProvider.new
      end

      def test_hovers_function_tag
        result = "### [function](https://documentation.platformos.com/api-reference/liquid/tags/function)\nAllows to store a variable returned by a partial. Partial needs to return data with `return` tag.\nAll variables needs to be passed explicitly to function. Variables from upper scope are not visible in function.\n*Note:* `context` is not available inside the function partial unless explicitly passed as a variable."

        assert_can_hover_with(@provider, "{% func", result, 0, 0)
      end

      def test_hovers_function_tag_if_multilline_liquid
        result = "### [function](https://documentation.platformos.com/api-reference/liquid/tags/function)\nAllows to store a variable returned by a partial. Partial needs to return data with `return` tag.\nAll variables needs to be passed explicitly to function. Variables from upper scope are not visible in function.\n*Note:* `context` is not available inside the function partial unless explicitly passed as a variable."

        markup = <<~END
          <p>This is a nice test</p>
          {{ "var" }}
          {% liquid
            graphql xyz = 'hello'
            function abc = "ds"
            funct
          %}
        END
        assert_can_hover_with(@provider, markup, result, 0, 5)
      end
    end
  end
end
