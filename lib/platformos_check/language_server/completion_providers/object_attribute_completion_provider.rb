# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class ObjectAttributeCompletionProvider < CompletionProvider
      def completions(context, child_lookup = nil)
        content = context.content
        cursor = context.cursor

        return [] if content.nil?
        return [] unless (variable_lookup = VariableLookupFinder.lookup(context))
        return [] if content[cursor - 1] == "." && content[cursor - 2] == "."

        if child_lookup && child_lookup.lookups.any?
          variable_lookup.lookups = variable_lookup.lookups + child_lookup.lookups
        end

        if variable_lookup.file_path
          function_completion(variable_lookup)
        elsif variable_lookup.lookups.first&.start_with?('graphql/')
          graphql_completion(variable_lookup)
        else
          # Navigate through lookups until the last valid [object, property] level
          object, property = VariableLookupTraverser.lookup_object_and_property(variable_lookup)

          # If the last lookup level is incomplete/invalid, use the partial term
          # to filter object properties.
          partial = partial_property_name(property, variable_lookup)

          return [] unless object

          object
            .properties
            .select { |prop| partial.nil? || prop.name.start_with?(partial) }
            .map { |prop| property_to_completion(prop) }
        end
      end

      private

      def partial_property_name(property, variable_lookup)
        last_property = variable_lookup.lookups.last
        last_property if last_property != property&.name
      end

      def property_to_completion(prop)
        content = PlatformosLiquid::Documentation.render_doc(prop)

        {
          label: prop.name,
          kind: CompletionItemKinds::PROPERTY,
          **format_hash(prop),
          **doc_hash(content)
        }
      end

      def find_file(file_name)
        @storage
          .platformos_app
          .all
          .find { |t| t.name == file_name }
      end

      def graphql_completion(variable_lookup)
        graphql_file_name = variable_lookup.lookups.first.sub(/graphql\//, '')
        graphql_file = find_file(graphql_file_name)
        fields = GraphqlTraverser.new(graphql_file).fields
        variable_path = File.join('', variable_lookup.lookups.slice(1..-1))
        variable_properties = fields[variable_path]

        variable_properties.map { |property| graphql_to_property_completion(property) }
      end

      def graphql_to_property_completion(property)
        hash = {
          'name' => property
        }
        object_entry = PlatformosLiquid::SourceIndex::ObjectEntry.new(hash)
        property_to_completion(object_entry)
      end

      def function_completion(variable_lookup)
          liquid_file = find_file(variable_lookup.file_path)
          partial_cursor = liquid_file.source.rindex("\n")
          partial_content = liquid_file.source
          lines = partial_content.split("\n")
          partial_provider = ObjectAttributeCompletionProvider.new(@storage)

          line_number_with_return = lines.rindex { |x| x.include?('return') }
          partial_context = CompletionContext.new(
            @storage,
            liquid_file.relative_path.to_s,
            line_number_with_return,
            lines[line_number_with_return].size
          )
          partial_provider.completions(partial_context, variable_lookup)
      end
    end
  end
end
