# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Session < Liquid::Tag
      SYNTAX = /(#{Liquid::VariableSignature}+)\s*=\s*(.*)\s*/om

      attr_reader :from

      def initialize(tag_name, markup, options)
        super
        raise Liquid::SyntaxError, "Syntax Error in 'session' - Valid syntax: session [var1] = [var2]" unless markup =~ SYNTAX

        @to = Regexp.last_match(1)
        @from = Liquid::Variable.new(Regexp.last_match(2), options)
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [
            @node.from
          ]
        end
      end
    end
  end
end
