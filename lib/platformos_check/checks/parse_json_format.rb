# frozen_string_literal: true

module PlatformosCheck
  class ParseJsonFormat < LiquidCheck
    severity :style
    category :liquid
    doc docs_url(__FILE__)

    def initialize(start_level: 0, indent: '  ')
      @pretty_json_opts = {
        indent:,
        start_level:
      }
    end

    def on_parse_json(node)
      parse_json = node.inner_json
      return if parse_json.nil?

      pretty_parse_json = pretty_json(parse_json, **@pretty_json_opts)
      return unless pretty_parse_json != node.inner_markup

      add_offense(
        "JSON formatting could be improved",
        node:
      ) do |corrector|
        corrector.replace_inner_json(node, parse_json, **@pretty_json_opts)
      end
    end
  end
end
