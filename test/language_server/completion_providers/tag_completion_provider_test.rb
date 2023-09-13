# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class TagCompletionProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @provider = TagCompletionProvider.new
      end

      def test_can_complete?
        assert_can_complete(@provider, "{% ", 0, 0)
        assert_can_complete(@provider, "{%  ", 0, 0)
        assert_can_complete(@provider, "{% rend", 0, 0)
        assert_can_complete(@provider, "{% rend", 0, 0)
        assert_can_complete(@provider, "{% rend %}", -3, 0)

        refute_can_complete(@provider, "{{  ", 0, 0)
        refute_can_complete(@provider, "{% if foo", 0, 0)
      end

      def test_completions
        assert_can_complete_with(@provider, "{% rend", "render", 0, 0)
        assert_can_complete_with(@provider, "{% comm", "comment", 0, 0)
      end

      def test_completions_with_tag_not_in_source_index
        skip "Not supported yet"
        tag_not_in_source_index = 'ifchanged'

        assert_includes(PlatformosLiquid::Tag::LABELS_NOT_IN_SOURCE_INDEX, tag_not_in_source_index)
        assert_can_complete_with(@provider, "{% ", tag_not_in_source_index, 0, 0)
      end

      def test_complete_block_ends
        skip "Not supported yet"

        assert_can_complete_with(@provider, "{% end", "endcomment", 0, 0)
        assert_can_complete_with(@provider, "{% endcomm", "endcomment", 0, 0)
      end
    end
  end
end
