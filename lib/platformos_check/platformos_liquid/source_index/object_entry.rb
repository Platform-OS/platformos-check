# frozen_string_literal: true

module PlatformosCheck
  module PlatformosLiquid
    class SourceIndex
      class ObjectEntry < BaseEntry
        def properties
          (hash['properties'] || [])
            .map do |prop_hash|
              PropertyEntry.new(prop_hash, hash['name'])
            end
        end

        def platformos_documentation_url
          "#{PLATFORMOS_DOCUMENTATION_URL}/developer-guide/variables/context-variable##{hash['name']}"
        end

        def global?
          hash.dig('access', 'global')
        end
      end
    end
  end
end
