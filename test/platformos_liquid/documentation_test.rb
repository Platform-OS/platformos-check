# frozen_string_literal: true

require 'test_helper'

module PlatformosCheck
  module PlatformosLiquid
    class DocumentationTest < Minitest::Test
      def test_filter_doc
        SourceIndex.stubs(:filters).returns([filter_entry])

        actual_doc = Documentation.filter_doc('size')
        expected_doc = "### [size](https://documentation.platformos.com/api-reference/liquid/filters/size)\n" \
                       "Returns the size of a string or array.\n" \
                       "\n---\n\n" \
                       'You can use the "size" filter with dot notation.'

        assert_equal(expected_doc, actual_doc)
      end

      def test_tag_doc
        SourceIndex.stubs(:tags).returns([tag_entry])

        actual_doc = Documentation.tag_doc('tablerow')
        expected_doc = "### [tablerow](https://documentation.platformos.com/api-reference/liquid/tags/tablerow)\n" \
                       'The "tablerow" tag must be wrapped in HTML "table" tags.' \

        assert_equal(expected_doc, actual_doc)
      end

      def test_object_doc
        skip "To be fixed"
        SourceIndex.stubs(:objects).returns([object_entry])

        actual_doc = Documentation.object_doc('context')
        expected_doc = "### [context](https://documentation.platformos.com/developer-guide/variables/context-variable)\n" \
                       'Context variable'

        assert_equal(expected_doc, actual_doc)
      end

      def test_object_property_doc
        skip "To be fixed"
        SourceIndex.stubs(:objects).returns([object_entry])

        actual_doc = Documentation.object_property_doc('context', 'location')
        expected_doc = "### [context](https://documentation.platformos.com/developer-guide/variables/context-variable#location)\n" \
                       'Context variable - location'

        assert_equal(expected_doc, actual_doc)
      end

      private

      def filter_entry
        SourceIndex::FilterEntry.new(
          'name' => 'size',
          'summary' => 'Returns the size of a string or array.',
          'description' => 'You can use the "size" filter with dot notation.'
        )
      end

      def object_entry
        SourceIndex::ObjectEntry.new(
          'name' => 'product',
          'summary' => 'A product in the store.',
          'properties' => [
            {
              'summary' => 'Returns "true" if at least one of the variants of the product is available.',
              'name' => 'available',
              'return_type' => [{ 'type' => 'string' }]
            }
          ]
        )
      end

      def tag_entry
        SourceIndex::TagEntry.new(
          'name' => 'tablerow',
          'summary' => 'The "tablerow" tag must be wrapped in HTML "table" tags.'
        )
      end
    end
  end
end
