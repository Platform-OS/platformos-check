# frozen_string_literal: true

require 'yaml'

module PlatformosCheck
  module PlatformosLiquid
    module Filter
      extend self

      def labels
        @labels ||= SourceIndex.filters.map(&:name)
      end

      def aliases
        @aliases ||= SourceIndex.filters.map(&:aliases).flatten
      end
    end
  end
end
