# frozen_string_literal: true

require 'test_helper'

module PlatformosCheck
  module PlatformosLiquid
    class SourceIndex
      class FilterStateTest < Minitest::Test
        def test_state_changes
          FilterState.mark_up_to_date

          refute_predicate(FilterState, :outdated?)

          FilterState.mark_outdated

          assert_predicate(FilterState, :outdated?)
        end
      end
    end
  end
end
