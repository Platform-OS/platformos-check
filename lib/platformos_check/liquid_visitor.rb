# frozen_string_literal: true

module PlatformosCheck
  class LiquidVisitor
    attr_reader :checks

    def initialize(checks, disabled_checks, only_single_file: false)
      @checks = checks
      @disabled_checks = disabled_checks
      @only_single_file = only_single_file
    end

    def visit_liquid_file(liquid_file)
      visit(LiquidNode.new(liquid_file.root, nil, liquid_file))

      if @only_single_file
        checks.single_file_end_dependencies(liquid_file).each do |file|
          visit(LiquidNode.new(file.root, nil, file))
        end
      end
    rescue Liquid::Error => e
      e.template_name = liquid_file.relative_path
      call_checks(:on_error, e)
    end

    private

    def visit(node)
      call_checks(:on_node, node)
      call_checks(:on_tag, node) if node.tag?
      call_checks(:"on_#{node.type_name}", node)
      node.children.each { |child| visit(child) }
      unless node.literal?
        call_checks(:"after_#{node.type_name}", node)
        call_checks(:after_tag, node) if node.tag?
        call_checks(:after_node, node)
      end

      @disabled_checks.update(node) if node.comment? || node.inline_comment?
    end

    def call_checks(method, *)
      checks.call(method, *)
    end
  end
end
