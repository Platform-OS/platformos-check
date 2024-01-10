# frozen_string_literal: true

module PlatformosCheck
  # Recommends replacing `include` for `render`
  class ConvertIncludeToRender < LiquidCheck
    RENDER_INCOMPATIBLE_TAGS = %w[break include].freeze

    severity :suggestion
    category :liquid
    doc docs_url(__FILE__)

    def initialize
      @processed_files = {}
    end

    def on_include(node)
      return if allowed_usecase?(node)

      add_offense("`include` is deprecated - convert it to `render`", node:) do |corrector|
        match = node.markup.match(/(?<include>include\s*)/)
        corrector.replace(node, node.markup.sub(match[:include], 'render '), node.start_index...node.end_index)
      end
    end

    protected

    def allowed_usecase?(node)
      return true if name_is_variable?(node)
      return true if include_node_contains_render_incompatible_tag?(root_node_from_include(node.value.template_name_expr))

      false
    end

    def name_is_variable?(node)
      !node.value.template_name_expr.is_a?(String)
    end

    def include_node_contains_render_incompatible_tag?(node)
      return false if node.nil?

      node.nodelist.any? do |n|
        if RENDER_INCOMPATIBLE_TAGS.include?(n.respond_to?(:tag_name) && n.tag_name)
          true
        elsif n.respond_to?(:nodelist) && n.nodelist
          include_node_contains_render_incompatible_tag?(n)
        else
          false
        end
      end
    end

    def root_node_from_include(path)
      @platformos_app.grouped_files[PlatformosCheck::PartialFile][path]&.parse&.root
    end
  end
end
