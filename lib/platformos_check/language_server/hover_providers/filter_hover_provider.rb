# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class FilterHoverProvider < HoverProvider
      NAMED_FILTER = /#{Liquid::FilterSeparator}\s*(\w+)/o
      FILTER_SEPARATOR_INCLUDING_SPACES = /\s*#{Liquid::FilterSeparator}/
      INPUT_TYPE_VARIABLE = 'variable'

      def completions(context)
        content = context.content
        cursor = context.cursor

        return [] if content.nil?
        return [] unless can_complete?(content, cursor)

        context = context_with_cursor_before_potential_filter_separator(context)
        variable_lookup = VariableLookupFinder.lookup(context)
        denied_filters = denied_filters_for(variable_lookup)
        available_filters_for(determine_input_type(variable_lookup))
          .select { |filter| (filter.name == partial(content, cursor)) && denied_filters.none?(filter.name) }
          .map { |filter| filter_to_completion(filter) }
          .first
      end

      def can_complete?(content, cursor)
        content.match?(Liquid::FilterSeparator) && (
          cursor_on_start_content?(content, cursor, Liquid::FilterSeparator) ||
          cursor_on_filter?(content, cursor)
        )
      end

      private

      def context_with_cursor_before_potential_filter_separator(context)
        content = context.content
        diff = content.index(FILTER_SEPARATOR_INCLUDING_SPACES) - context.cursor

        return context unless content.scan(FILTER_SEPARATOR_INCLUDING_SPACES).size == 1

        context.clone_and_overwrite(col: context.col + diff)
      end

      def determine_input_type(variable_lookup)
        return if variable_lookup.nil?

        object, property = VariableLookupTraverser.lookup_object_and_property(variable_lookup)
        return property.return_type if property

        object&.name
      end

      def denied_filters_for(variable_lookup)
        return [] if variable_lookup.nil?

        VariableLookupTraverser.find_object(variable_lookup.name)&.denied_filters || []
      end

      def available_filters_for(input_type)
        filters = PlatformosLiquid::SourceIndex.filters
                                               .select { |filter| input_type.nil? || filter.input_type == input_type }
        return all_labels if filters.empty?
        return filters if input_type == INPUT_TYPE_VARIABLE

        filters + available_filters_for(INPUT_TYPE_VARIABLE)
      end

      def all_labels
        available_filters_for(nil)
      end

      def cursor_on_filter?(content, cursor)
        return false unless content.match?(NAMED_FILTER)

        matches(content, NAMED_FILTER).any? do |match|
          match.begin(1) <= cursor && cursor < match.end(1) + 1 # including next character
        end
      end

      def partial(content, cursor)
        return '' unless content.match?(NAMED_FILTER)

        partial_match = matches(content, NAMED_FILTER).find do |match|
          match.begin(1) <= cursor && cursor < match.end(1) + 1 # including next character
        end
        return '' if partial_match.nil?

        partial_match[1]
      end

      def param_to_doc(param)
        "#{param.name}:#{param.return_type.downcase}"
      end

      def filter_to_completion(filter)
        content = PlatformosLiquid::Documentation.render_doc(filter)
        first_param, *other_params = filter.parameters
        other_params = other_params.map { |param| param_to_doc(param) }
        other_params = other_params.any? ? ": #{other_params.join(', ')}" : ""
        content = "#{param_to_doc(first_param)} | #{filter.name}#{other_params} => #{filter.return_type}"

        {
          contents: content,

          # label: filter.name,
          # kind: CompletionItemKinds::FUNCTION,
          # **format_hash(filter),
          # **doc_hash(content)
        }
      end
    end
  end
end
