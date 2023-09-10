# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Background < Base
      PARTIAL_SYNTAX = /(#{Liquid::VariableSignature}+)\s*=\s*(.*)\s*/om
      CLOSE_TAG_SYNTAX = /\A(.*)(?-mix:\{%-?)\s*(\w+)\s*(.*)?(?-mix:%\})\z/m # based on Liquid::Raw::FullTokenPossiblyInvalid

      attr_reader :to, :from, :attributes, :value_expr, :partial_syntax, :partial_name

      def initialize(tag_name, markup, options)
        if markup =~ PARTIAL_SYNTAX
          super
          @to = Regexp.last_match(1)
          @partial_syntax = true

          after_assign_markup = Regexp.last_match(2).split('|')
          parse_markup(tag_name, after_assign_markup.shift)
          after_assign_markup.unshift(@to)
          @partial_name = value_expr
          @from = Liquid::Variable.new(after_assign_markup.join('|'), options)
        else
          @partial_syntax = false
          parse_markup(tag_name, markup)
          super
        end
        @attributes = attributes_expr
      end

      def parse(tokens)
        return super if @partial_syntax

        @body = +''
        while (token = tokens.send(:shift))
          if token =~ CLOSE_TAG_SYNTAX && block_delimiter == Regexp.last_match(2)
            @body << Regexp.last_match(1) if Regexp.last_match(1) != ''
            return
          end
          @body << token unless token.empty?
        end

        raise Liquid::SyntaxError, parse_context.locale.t('errors.syntax.tag_never_closed', block_name:)
      end

      def block_name
        @tag_name
      end

      def block_delimiter
        @block_delimiter = "end#{block_name}"
      end

      def parse_main_value(tag_name, markup)
        raise Liquid::SyntaxError, "Invalid syntax for #{tag_name} tag" unless markup =~ syntax

        @main_value = Regexp.last_match(1)
        @value_expr = @main_value ? Liquid::Expression.parse(@main_value) : nil
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [
            @node.to
          ].compact + @node.attributes_expr.values
        end
      end
    end
  end
end
