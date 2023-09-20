# frozen_string_literal: true

require 'graphql'

module PlatformosCheck
  class GraphqlTraverser
    def initialize(graphql_file)
      @graphql_file = graphql_file
    end

    def fields
      pickup_fields(@graphql_file.selections, '')
    end

    private

    def pickup_fields(selections, path = '')
      selections = expand_fragments(selections)
      fields = {}
      fields['/'] = map_names_from_selections(selections) if path.empty?
      selections.map do |selection|
        current_path = File.join(path, name_from_selection(selection))
        fields[current_path] = map_names_from_selections(expand_fragments(selection.selections))

        child_fields = pickup_fields(selection.selections, current_path)
        fields = fields.merge(child_fields)
      end
      fields
    end

    def map_names_from_selections(selections)
      selections.map{ |selection| name_from_selection(selection) }
    end

    def name_from_selection(selection)
      selection.alias || selection.name
    end

    def expand_fragments(selections)
      selections.map do |selection|
        if selection.is_a?(GraphQL::Language::Nodes::FragmentSpread)
          find_fragment(selection.name).selections
        else
          selection
        end
      end.flatten.uniq { |s| s.name }
    end

    def find_fragment(fragment_name)
      @graphql_file.fragments.detect { |definition| definition.name == fragment_name }
    end
  end
end
