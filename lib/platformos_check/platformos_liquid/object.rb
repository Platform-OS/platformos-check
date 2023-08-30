# frozen_string_literal: true

require 'yaml'

module PlatformosCheck
  module PlatformosLiquid
    module Object
      extend self

      def labels
        @labels ||= SourceIndex.objects.map(&:name)
      end
    end
  end
end
