# frozen_string_literal: true

require 'yaml'

module PlatformosCheck
  module PlatformosLiquid
    module Filter
      extend self

      def labels
        @labels ||= SourceIndex.filters.each_with_object([]) do |f, arr|
          arr << f.name
          arr + f.aliases
        end
      end
    end
  end
end
