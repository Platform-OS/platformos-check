# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    module VariableLookupFinder
      class AssignmentsFinder
        class Scope < Struct.new(:variables, :parent)
          include TypeHelper

          def new_child
            child_scope = dup
            child_scope.variables = variables.dup
            child_scope.parent = self
            child_scope
          end

          def <<(node)
            tag = node.value

            case tag
            when Liquid::Assign
              variable_name = tag.to
              variables[variable_name] = as_potential_lookup(tag.from.name)
            when Tags::Function
              variable_name = tag.to
              variables[variable_name] = literal_lookup(tag.from)
            when Tags::Graphql
              variable_name = tag.to
              potential = as_potential_lookup_graphql(tag)
              variables[variable_name] = potential
            when Liquid::For, Liquid::TableRow
              variable_name = tag.variable_name
              variables[variable_name] = as_potential_lookup(tag.collection_name, ['first'])
            end
          end

          private

          def as_potential_lookup(variable_lookup, default_lookups = [])
            case variable_lookup
            when Liquid::VariableLookup
              potential_lookup(variable_lookup, default_lookups)
            when Liquid::RangeLookup
              as_potential_lookup(variable_lookup.start_obj)
            when Enumerable
              as_potential_lookup(variable_lookup.first)
            else
              literal_lookup(variable_lookup)
            end
          end

          def literal_lookup(variable_lookup)
            name = input_type_of(variable_lookup)
            PotentialLookup.new(name, [], variables)
          end

          def potential_lookup(variable_lookup, default_lookups)
            name = variable_lookup.name
            lookups = variable_lookup.lookups.concat(default_lookups)

            PotentialLookup.new(name, lookups, variables)
          end

          def as_potential_lookup_graphql(tag)
            variable_lookup = tag.from.name
            name = variable_lookup
            lookups = variable_lookup.lookups.concat([])

            # TODO: this is smelly
            PotentialLookup.new(name, ["graphql/#{tag.partial_name}"], variables)
          end
        end
      end
    end
  end
end
