# frozen_string_literal: true

module PlatformosCheck
  # Reports deeply nested {% include ... %} or {% render ... %}
  class NestedSnippet < LiquidCheck
    severity :suggestion
    category :liquid
    doc docs_url(__FILE__)

    class TemplateInfo < Struct.new(:includes)
      def with_deep_nested(templates, max, current_level = 0)
        includes.each do |node|
          if current_level >= max
            yield node
          else
            template_name = "snippets/#{node.value.template_name_expr}"
            templates[template_name]
              &.with_deep_nested(templates, max, current_level + 1) { yield node }
          end
        end
      end
    end

    def initialize(max_nesting_level: 3)
      @max_nesting_level = max_nesting_level
      @templates = {}
    end

    def on_document(node)
      @templates[node.platformos_app_file.name] = TemplateInfo.new(Set.new)
    end

    def on_include(node)
      return unless node.value.template_name_expr.is_a?(String)

      @templates[node.platformos_app_file.name].includes << node
    end
    alias on_render on_include

    def on_end
      @templates.each_pair do |_, info|
        info.with_deep_nested(@templates, @max_nesting_level) do |node|
          add_offense("Too many nested snippets", node:)
        end
      end
    end
  end
end
