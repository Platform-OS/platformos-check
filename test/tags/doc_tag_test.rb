# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module Tags
    class DocTagTest < Minitest::Test
      def test_doc_tag_without_parameters
        offenses = analyze_platformos_app(
          "app/views/pages/index.liquid" => <<~END
            {% doc %}
              This is a documentation block.
              It can contain notes about the code.
            {% enddoc %}
          END
        )

        assert_offenses("", offenses)
      end

      def test_doc_tag_with_parameters_fails
        offenses = analyze_platformos_app_without_raise(
          PlatformosCheck::SyntaxError.new,
          "app/views/pages/index.liquid" => <<~END
            {% doc arg: 1 %}
              Documentation
            {% enddoc %}
          END
        )

        assert_equal(1, offenses.size)
        assert_match(/syntax error/i, offenses.first.message.downcase)
      end

      def test_doc_tag_with_content
        offenses = analyze_platformos_app(
          "app/views/pages/index.liquid" => <<~END
            {% doc %}
              # API Documentation
              This function handles user authentication
              Parameters:
              - email: String
              - password: String
            {% enddoc %}
          END
        )

        assert_offenses("", offenses)
      end
    end
  end
end
