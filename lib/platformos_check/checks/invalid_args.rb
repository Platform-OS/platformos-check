# frozen_string_literal: true

module PlatformosCheck
  class InvalidArgs < LiquidCheck
    class ParsedGraphQL
      def initialize(ast)
        @ast = ast
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

      attr_reader :ast

      def variables
        @variables ||= definition&.variables || []
      end

      def definition
        @definition ||= ast.definitions.detect { |d| d.is_a?(GraphQL::Language::Nodes::OperationDefinition) }
      end
    end
    severity :error
    category :liquid, :graphql
    doc docs_url(__FILE__)

    def on_render(node)
      add_duplicated_key_offense(node)
    end

    def on_function(node)
      add_duplicated_key_offense(node)
    end

    def on_graphql(node)
      add_duplicated_key_offense(node)

      return if node.value.inline_query

      graphql_partial = node.value.partial_name
      return unless graphql_partial.is_a?(String)

      graqphql_file = platformos_app.grouped_files[GraphqlFile][graphql_partial]
      return unless graqphql_file

      provided_arguments = node.value.attributes

      return if provided_arguments.include?('args')

      parsed_graphql = ParsedGraphQL.new(graqphql_file.parse)

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

    def add_duplicated_key_offense(node)
      node.value.duplicated_attrs.each do |duplicated_arg|
        add_offense("Duplicated argument `#{duplicated_arg}`", node:)
      end
    end
  end
end
