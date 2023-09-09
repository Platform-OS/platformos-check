# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class FilterHoverProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @provider = FilterHoverProvider.new
      end

      def test_hovers
        assert_can_hover_with(@provider, "{{ 'foo.js' | asset_url", 'file_path:string | asset_url => string')
        assert_can_hover_with(@provider, "{{ foo | array_group_by", 'objects:array<object> | array_group_by: method_name:string => hash<methodresult => array<object>>')
        assert_can_hover_with(@provider, "{{ obj | hash_merge", 'hash1:hash | hash_merge: hash2:hash => hash')
      end

      def test_hover_in_assign_tag
        assert_can_hover_with(@provider, "{% assign url = url | append: '#' | append", 'object:untyped | append => string')
      end
    end
  end
end
