# frozen_string_literal: true

module PlatformosCheck
  class GraphqlInForLoop < LiquidCheck
    severity :suggestion
    categories :liquid, :performance
    doc docs_url(__FILE__)

    PARTIAL_TAG = %i[render include]
    OFFENSE_MSG = "Do not invoke GraphQL in a for loop"

    class PartialInfo
      attr_reader :node, :app_file

      def initialize(node:, app_file:)
        @node = node
        @app_file = app_file
      end
    end

    def self.single_file(**_args)
      true
    end

    def initialize
      @partials = []
      @all_partials = Set.new
    end

    def on_for(_node)
      @in_for = true
    end

    def on_graphql(node)
      add_graphql_offense(node:, graphql_node: node) if should_report?
    end

    def after_for(_node)
      @in_for = false
    end

    def on_background(_node)
      @in_background = true
    end

    def after_background(_node)
      @in_background = false
    end

    def on_include(node)
      return unless should_report?

      add_partial(path: node.value.template_name_expr, node:)
    end

    def on_render(node)
      return unless should_report?

      add_partial(path: node.value.template_name_expr, node:)
    end

    def on_function(node)
      return unless should_report?

      add_partial(path: node.value.from, node:)
    end

    def on_end
      while (partial_info = @partials.shift)
        report_offense_on_graphql(LiquidNode.new(partial_info.app_file.parse.root, nil, partial_info.app_file), offense_node: partial_info.node)
      end
    end

    protected

    def add_partial(path:, node:)
      return unless path.is_a?(String)
      return if @all_partials.include?(path)
      return if @platformos_app.grouped_files[PlatformosCheck::PartialFile][path].nil?

      @all_partials << path
      @partials << PartialInfo.new(node:, app_file: @platformos_app.grouped_files[PlatformosCheck::PartialFile][path])
    end

    def should_report?
      @in_for && !@in_background
    end

    def add_graphql_offense(node:, graphql_node:)
      return add_offense(OFFENSE_MSG, node:) unless graphql_node.value.partial_name

      partial_name = graphql_node.value.partial_name.is_a?(String) ? graphql_node.value.partial_name : "variable: #{graphql_node.value.partial_name.name}"
      add_offense("#{OFFENSE_MSG} (#{partial_name})", node:)
    end

    def report_offense_on_graphql(node, offense_node:)
      if node.type_name == :graphql
        add_graphql_offense(node: offense_node, graphql_node: node)
      elsif PARTIAL_TAG.include?(node.type_name)
        add_partial(path: node.value.template_name_expr, node: offense_node)
      elsif node.type_name == :function
        add_partial(path: node.value.from, node: offense_node)
      elsif node.children && !node.children.empty?
        node.children.each { |c| report_offense_on_graphql(c, offense_node:) }
      end
    end
  end
end
