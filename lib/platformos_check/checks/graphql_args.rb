# frozen_string_literal: true

require 'graphql'

module PlatformosCheck
  class GraphqlArgs < LiquidCheck
    class ParsedGraphQL
      def initialize(graphql_source)
        @graphql_source = graphql_source
      end

      def required_arguments
        variables.each_with_object([]) do |v, vars|
          vars << v.name if v.type.is_a?(GraphQL::Language::Nodes::NonNullType)
        end
      end

      def defined_arguments
        variables.map(&:name)
      end

      private

      attr_reader :graphql_source

      def ast
        @ast ||= GraphQL.parse(graphql_source)
      end

      def variables
        @variables ||= ast.definitions.first&.variables || []
      end
    end
    severity :error
    category :liquid, :graphql
    doc docs_url(__FILE__)

    def on_graphql(node)
      return if node.value.inline_query

      graphql_partial = node.value.partial_name
      return unless graphql_partial.is_a?(String)

      graqphql_file = platformos_app.grouped_files[GraphqlFile][graphql_partial]
      return unless graqphql_file

      provided_arguments = node.value.attributes_expr.keys

      return if provided_arguments.include?('args')

      graphql_source = graqphql_file.source

      parsed_graphql = ParsedGraphQL.new(graphql_source)

      required_arguments = parsed_graphql.required_arguments
      defined_arguments = parsed_graphql.defined_arguments

      (provided_arguments - defined_arguments).each do |name|
        add_offense("Undefined argument `#{name}` provided to `#{graqphql_file.relative_path}`", node:)
      end

      (required_arguments - provided_arguments).each do |name|
        add_offense("Required argument `#{name}` not provided to `#{graqphql_file.relative_path}`", node:)
      end
    rescue GraphQL::ParseError => e
      add_offense("GraphQL Parse error triggered by `#{graqphql_file.relative_path}`: #{e.message}", node:)
    end
  end
end
