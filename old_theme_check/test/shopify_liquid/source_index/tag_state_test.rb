# frozen_string_literal: true

require 'test_helper'

module PlatformosCheck
  module ShopifyLiquid
    class SourceIndex
      class TagStateTest < Minitest::Test
        def test_state_changes
          TagState.mark_up_to_date

          refute_predicate(TagState, :outdated?)

          TagState.mark_outdated

          assert_predicate(TagState, :outdated?)
        end
      end
    end
  end
end
