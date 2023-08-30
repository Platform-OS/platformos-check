# frozen_string_literal: true

module PlatformosCheck
  # Reports missing content_for_layout in layouts
  class RequiredLayoutObject < LiquidCheck
    severity :error
    category :liquid
    doc docs_url(__FILE__)

    def initialize
      @content_for_layout_found = false
    end

    def on_document(node)
      @layout_platformos_app_node = node if node.app_file.layout?
    end

    def on_variable(node)
      return unless node.value.name.is_a?(Liquid::VariableLookup)

      @content_for_layout_found ||= node.value.name.name == "content_for_layout"
    end

    def after_document(node)
      return unless node.app_file.layout?

      add_missing_object_offense("content_for_layout", "</body>") unless @content_for_layout_found
    end

    private

    def add_missing_object_offense(name, tag)
      add_offense("layout must include {{#{name}}}", node: @layout_platformos_app_node) do
        if @layout_platformos_app_node.source.index(tag)
          @layout_platformos_app_node.source.insert(@layout_platformos_app_node.source.index(tag), "  {{ #{name} }}\n  ")
          @layout_platformos_app_node.markup = @layout_platformos_app_node.source
        end
      end
    end
  end
end
