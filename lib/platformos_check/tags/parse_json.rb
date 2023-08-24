# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class ParseJson < Liquid::Block
      SYNTAX = /(#{Liquid::VariableSignature}+)/o

      attr_reader :to

      def initialize(tag_name, markup, options)
        super
        raise SyntaxError, options[:locale].t('errors.syntax.parse_json', default: "Syntax Error in 'capture' - Valid syntax: parse_json [var]") unless markup =~ SYNTAX

        @to = Regexp.last_match(1)
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [
            @node.to
          ]
        end
      end
    end
  end
end
