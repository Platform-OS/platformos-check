# frozen_string_literal: true

module PlatformosCheck
  class UnreachableCode < LiquidCheck
    severity :error
    category :liquid
    doc docs_url(__FILE__)

    FLOW_COMMAND = %i[break continue return]
    CONDITION_TYPES = Set.new(%i[condition else_condition])
    INCLUDE_FLOW_COMMAND = %w[break]

    def on_document(node)
      @processed_files = {}
      check_unreachable_code(node.children)
    end

    protected

    def check_unreachable_code(nodes)
      nodes = sanitize_children(nodes)
      nodes.each_cons(2) do |node1, _node2|
        next unless flow_expression?(node1)

        add_offense("Unreachable code after `#{node1.type_name}`", node: node1)
      end
      flow_expression?(nodes.last)
    end

    def sanitize_children(children)
      children.reject { |c| c.value.is_a?(String) && c.value.strip == '' }
    end

    def flow_expression?(node)
      return false if node.nil?
      return true if flow_command?(node)

      case node.type_name
      when :if, :unless
        check_if(node)
        false
      when :for
        check_for(node)
        false
      when :case
        check_case(node)
        false
      when :try_rc, :try
        check_try(node)
        false
      when :block_body
        node.children.any? { |c| flow_expression?(c) }
      else
        false
      end
    end

    def check_if(node)
      node.children.each do |condition|
        check_unreachable_code(condition.children.detect(&:block_body?).children)
      end
    end

    def check_for(node)
      check_unreachable_code(node.children.detect(&:block_body?).children)
    end

    def check_case(node)
      node.children.each do |condition|
        next unless CONDITION_TYPES.include?(condition.type_name)

        check_unreachable_code(condition.children.detect(&:block_body?).children)
      end
    end

    def check_try(node)
      node.children.each do |block_body|
        check_unreachable_code(block_body.children)
      end
    end

    def flow_command?(node)
      return true if FLOW_COMMAND.include?(node.type_name)

      return evaluate_include(node.value.template_name_expr) if node.type_name == :include && node.value.template_name_expr.is_a?(String)

      false
    end

    def evaluate_include(path)
      return false unless path.is_a?(String)

      @processed_files[path] ||= include_node_contains_flow_command?(@platformos_app.grouped_files[PlatformosCheck::PartialFile][path]&.parse&.root)
      @processed_files[path]
    end

    def include_node_contains_flow_command?(root)
      return false if root.nil?

      root.nodelist.any? do |node|
        if INCLUDE_FLOW_COMMAND.include?(node.respond_to?(:tag_name) && node.tag_name)
          true
        elsif node.respond_to?(:nodelist) && node.nodelist
          include_node_contains_flow_command?(node)
        elsif node.respond_to?(:tag_name) && node.tag_name == 'include' && node.template_name_expr.is_a?(String)
          evaluate_include(node.template_name_expr)
        else
          false
        end
      end
    end
  end
end
