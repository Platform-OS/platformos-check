# frozen_string_literal: true

require 'cgi'

module PlatformosCheck
  module PlatformosLiquid
    class SourceIndex
      class FilterEntry < BaseEntry
        def parameters
          @parameters ||= (hash['parameters'] || []).map { |hash| ParameterEntry.new(hash) }
        end

        def summary
          hash['summary']&.strip == 'returns' ? nil : hash['summary']
        end

        def description
          @descritpion = begin
            desc = hash['description'].is_a?(Array) ? hash['description'].first : hash['description']
            desc = desc&.strip || ''
            desc = '' if desc == 'returns'
            if parameters.any?
              desc += "\n\n" unless desc.empty?
              desc += "Parameters:"
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
                input = example[0].strip
                output = example[1]&.strip
                desc += "\n  - Example #{i}:\n\n```liquid\n#{input}\n```"
                desc += "\n##\nOutput: #{output}" if output
              end
            end
          end
          desc
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
