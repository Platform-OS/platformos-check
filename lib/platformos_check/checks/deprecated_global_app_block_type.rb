# frozen_string_literal: true

module PlatformosCheck
  class DeprecatedGlobalAppBlockType < LiquidCheck
    severity :error
    category :liquid
    doc docs_url(__FILE__)

    INVALID_GLOBAL_APP_BLOCK_TYPE = "@global"
    VALID_GLOBAL_APP_BLOCK_TYPE = "@app"

    def on_schema(node)
      schema = node.inner_json
      return if schema.nil?

      return unless block_types_from(schema).include?(INVALID_GLOBAL_APP_BLOCK_TYPE)

      add_offense(
        "Deprecated '#{INVALID_GLOBAL_APP_BLOCK_TYPE}' block type defined in the schema, use '#{VALID_GLOBAL_APP_BLOCK_TYPE}' block type instead.",
        node:
      )
    end

    def on_case(node)
      return unless node.value == INVALID_GLOBAL_APP_BLOCK_TYPE

      report_offense(node)
    end

    def on_condition(node)
      return unless node.value.right == INVALID_GLOBAL_APP_BLOCK_TYPE || node.value.left == INVALID_GLOBAL_APP_BLOCK_TYPE

      report_offense(node)
    end

    def on_variable(node)
      return unless node.value.name == INVALID_GLOBAL_APP_BLOCK_TYPE

      report_offense(node)
    end

    private

    def report_offense(node)
      add_offense(
        "Deprecated '#{INVALID_GLOBAL_APP_BLOCK_TYPE}' block type, use '#{VALID_GLOBAL_APP_BLOCK_TYPE}' block type instead.",
        node:
      )
    end

    def block_types_from(schema)
      schema.fetch("blocks", []).map do |block|
        block.fetch("type", "")
      end
    end
  end
end
