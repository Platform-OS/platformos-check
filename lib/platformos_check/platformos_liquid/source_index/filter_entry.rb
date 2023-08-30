# frozen_string_literal: true

module PlatformosCheck
  module PlatformosLiquid
    class SourceIndex
      class FilterEntry < BaseEntry
        def parameters
          (hash['parameters'] || [])
            .map { |hash| ParameterEntry.new(hash) }
        end

        def aliases
          hash['aliases'] || []
        end

        def input_type
          @input_type ||= hash['syntax'].split(' | ')[0]
        end

        def platformos_documentation_url
          "#{PLATFORMOS_DOCUMENTATION_URL}/api-reference/liquid/filters/#{hash['name']}"
        end
      end
    end
  end
end
