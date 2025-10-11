# frozen_string_literal: true

module PlatformosCheck
  class UnusedPartial < LiquidCheck
    severity :suggestion
    category :liquid
    doc docs_url(__FILE__)

    def initialize
      @used_partials = Set.new
    end

    def on_render(node)
      if node.value.template_name_expr.is_a?(String)
        @used_partials << node.value.template_name_expr

      elsif might_have_a_block_as_variable_lookup?(node)
        # We ignore this case, because that's a "proper" use case for
        # the render tag with OS 2.0
        # {% render block %} shouldn't turn off the UnusedPartial check

      else
        # Can't reliably track unused partials if an expression is used, ignore this check
        @used_partials.clear
        ignore!
      end
    end
    alias on_include on_render

    def on_function(node)
      if node.value.from.is_a?(String)
        @used_partials << node.value.from
      else
        # Can't reliably track unused partials if an expression is used, ignore this check
        @used_partials.clear
        ignore!
      end
    end

    def on_end
      missing_partials.each do |app_file|
        # we want to duplicate the offense to not mark it as autocorrectible
        return add_offense("This partial is not used", app_file:) if app_file.module_file?

        add_offense("This partial is not used", app_file:) do |corrector|
          corrector.remove_file(@platformos_app.storage, app_file.relative_path.to_s)
        end
      end
    end

    def missing_partials
      platformos_app.partials.reject { |t| @used_partials.include?(t.name) }
    end

    private

    # This function returns true when the render node passed might have a
    # variable lookup that refers to a block as template_name_expr.
    #
    # e.g.
    #
    # {% for block in col %}
    #   {% render block %}
    # {% endfor %}
    #
    # In this case, the `block` variable_lookup in the render tag might be
    # a Block because col might be an array of blocks.
    #
    # @param node [Node]
    def might_have_a_block_as_variable_lookup?(node)
      return false unless node.type_name == :render

      return false unless node.value.template_name_expr.is_a?(Liquid::VariableLookup)

      name = node.value.template_name_expr.name
      return false unless name.is_a?(String)

      # We're going through all the parents of the nodes until we find
      # a For node with variable_name === to the template_name_expr's name
      find_parent(node.parent) do |parent_node|
        next false unless parent_node.type_name == :for

        parent_node.value.variable_name == name
      end
    end

    # @param node [Node]
    def find_parent(node, &)
      return nil unless node

      return node if yield node

      find_parent(node.parent, &)
    end
  end
end
