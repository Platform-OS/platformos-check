# frozen_string_literal: true

module PlatformosCheck
  # Checks unused {% assign x = ... %}
  class UnusedAssign < LiquidCheck
    severity :suggestion
    category :liquid
    doc docs_url(__FILE__)

    class TemplateInfo < Struct.new(:used_assigns, :assign_nodes, :includes)
      def collect_used_assigns(templates, visited = Set.new)
        collected = used_assigns
        # Check recursively inside included snippets for use
        includes.each do |name|
          if templates[name] && !visited.include?(name)
            visited << name
            collected += templates[name].collect_used_assigns(templates, visited)
          end
        end
        collected
      end
    end

    def initialize
      @templates = {}
    end

    def on_document(node)
      @templates[node.platformos_app_file.name] = TemplateInfo.new(Set.new, {}, Set.new)
    end

    def on_assign(node)
      @templates[node.platformos_app_file.name].assign_nodes[node.value.to] = node
    end

    def on_parse_json(node)
      @templates[node.platformos_app_file.name].assign_nodes[node.value.to] = node
    end

    def on_function(node)
      return if node.value.to.start_with?('_')

      @templates[node.platformos_app_file.name].assign_nodes[node.value.to] = node
    end

    def on_graphql(node)
      return if node.value.to.start_with?('_')

      @templates[node.platformos_app_file.name].assign_nodes[node.value.to] = node
    end

    def on_include(node)
      return unless node.value.template_name_expr.is_a?(String)

      @templates[node.platformos_app_file.name].includes << "snippets/#{node.value.template_name_expr}"
    end

    def on_variable_lookup(node)
      @templates[node.platformos_app_file.name].used_assigns << case node.value.name
                                                                when Liquid::VariableLookup
                                                                  node.value.name.name
                                                                else
                                                                  node.value.name
                                                                end
    end

    def on_end
      @templates.each_pair do |_, info|
        used = info.collect_used_assigns(@templates)
        info.assign_nodes.each_pair do |name, node|
          next if used.include?(name)

          add_offense("`#{name}` is never used", node:) do |corrector|
            case node.type_name
            when :function, :graphql
              offset = node.markup.index(node.value.to)

              corrector.insert_before(
                node,
                '_',
                (node.start_index + offset)...(node.start_index + offset)
              )
            else
              corrector.remove(node)
            end
          end
        end
      end
    end
  end
end
