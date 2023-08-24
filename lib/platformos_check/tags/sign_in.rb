# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class SignIn < Base
      SYNTAX = /\A([\w-]+[\s,]*[\w\s,]*)\s*(user_id:\s*(.+))?\z/
      VALID_ATTRUBTES = %w[user_id timeout_in_minutes].freeze

      def initialize(tag_name, markup, options)
        super

        raise Liquid::SyntaxError, "Syntax Error in 'sign_in' - Valid syntax: sign_in user_id: [user_id], timeout_in_minutes: [timeout_in_minutes]" if attributes_expr['user_id'].nil?

        wrong_attributes = attributes_expr.keys - VALID_ATTRUBTES
        raise Liquid::SyntaxError, "Syntax Error in 'sign_in' - Unknown argument(s): #{wrong_attributes.join(', ')}. Valid arguments: #{VALID_ATTRUBTES}" unless wrong_attributes.empty?
      end

      def parse_main_value(_tag_name, _markup); end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          @node.attributes_expr.values
        end
      end
    end
  end
end
