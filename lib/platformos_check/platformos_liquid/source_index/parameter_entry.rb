# frozen_string_literal: true

module PlatformosCheck
  module PlatformosLiquid
    class SourceIndex
      class ParameterEntry < BaseEntry
        def summary
          nil
        end

        def platformos_documentation_url
          "#{PLATFORMOS_DOCUMENTATION_URL}/api-reference/liquid/filters/#{hash['name']}"
        end

        private

        def return_type_hash
          {
            'type' => (hash['types'] || ['untyped']).first
          }
        end
      end
    end
  end
end
