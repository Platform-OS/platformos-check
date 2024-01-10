# frozen_string_literal: true

module PlatformosCheck
  # Recommends replacing `include` for `render`
  class IncludeInRender < LiquidCheck
    severity :error
    category :liquid
    doc docs_url(__FILE__)

    def initialize
      @processed_files = {}
    end

    def on_render(node)
      path = node.value.template_name_expr
      return unless include_tag_in_render?(root_node_for_render(path))

      add_offense("`render` context does not allow to use `include`, either remove all includes from `#{app_file_for_path(path).relative_path}` or change `render` to `include`", node:)
    end

    protected

    def include_tag_in_render?(node)
      return false if node.nil?

      node.nodelist.any? do |n|
        if n.respond_to?(:tag_name) && n.tag_name == 'include'
          true
        elsif n.respond_to?(:nodelist) && n.nodelist
          include_tag_in_render?(n)
        else
          false
        end
      end
    end

    def root_node_for_render(path)
      app_file_for_path(path)&.parse&.root
    end

    def app_file_for_path(path)
      @platformos_app.grouped_files[PlatformosCheck::PartialFile][path]
    end
  end
end
