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

        def description
          @descritpion = begin
            desc = hash['description']&.strip || ''
            desc = '' if desc == 'returns'
            if parameters.any?
              desc += "\n\n---\n\nParameters:"
              parameters.each { |p| desc += "\n- #{p.full_summary}" }
            end
            if hash['return_type']&.any?
              rt = hash['return_type'].first
              rt['description'] = nil if rt['description']&.strip == ''
              desc += "\n\nReturns:"
              desc += "\n- #{[rt['type'], rt['description']].compact.join(': ')}\n"
            end
            if hash['examples']
              desc += "\n\n---\n\n"
              hash['examples'].each_with_index do |e, i|
                example = e['raw_liquid'].gsub(/[\n]+/, "\n").strip.split('=>')
                input = example[0]&.strip
                output = example[1]&.strip
                desc += "\n  - Example #{i}:\n\n```liquid\n#{input}\n```"
                desc += "\n##\nOutput: #{output}" if output
              end
            end
          end
          desc
        end

        def platformos_documentation_url
          "#{PLATFORMOS_DOCUMENTATION_URL}/api-reference/liquid/tags/#{hash['name']}"
        end
      end
    end
  end
end
