# frozen_string_literal: true

module PlatformosCheck
  module PlatformosLiquid
    class SourceIndex
      class TagEntry < BaseEntry
        def parameters
          (hash['parameters'] || [])
            .map { |hash| ParameterEntry.new(hash) }
        end

        def return_type_hash
          {
            'type' => "tag<#{name}>"
          }
        end

        def platformos_documentation_url
          "#{PLATFORMOS_DOCUMENTATION_URL}/api-reference/liquid/tags/#{hash['name']}"
        end
      end
    end
  end
end
