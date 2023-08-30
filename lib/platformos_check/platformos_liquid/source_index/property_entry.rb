# frozen_string_literal: true

module PlatformosCheck
  module PlatformosLiquid
    class SourceIndex
      class PropertyEntry < BaseEntry
        attr_reader :parent_name

        def initialize(hash, parent_name)
          @hash = hash || {}
          @return_type = nil
          @parent_name = parent_name
        end

        def platformos_documentation_url
          "#{PLATFORMOS_DOCUMENTATION_URL}/developer-guide/variables/context-variable##{@parent_name}"
        end
      end
    end
  end
end
