# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Function < Base
      # SYNTAX_HASH @to is the same as for hash_assign tag, but with mandatory brackets
      SYNTAX_HASH = %r{((\(?[\w\-.]\)?)+)(\[.+\])+\s*=\s*([\w/\-."']+)\s*(.*)}om
      # SYNTAX_VARIABLE @to is the original Liquid::VariableSignature but with bracket
      # characters removed
      SYNTAX_VARIABLE = %r{((?-mix:\(?[\w\-.]\)?)+)\s*=\s*([\w/\-."']+)\s*(.*)}om

      attr_reader :to, :from, :attributes

      def initialize(tag_name, markup, options)
        super
        if markup =~ SYNTAX_VARIABLE
          @to = Regexp.last_match(1)
          @from = Liquid::Expression.parse(Regexp.last_match(2))
          # Rest of markup contains only the function parameters, an improvement made in
          # another PR as well, to avoid other parts of the markup containing special
          # characters from conflicting with ::Liquify::Tags::BaseTagMethods::TAG_ATTRIBUTES
          @rest_of_markup = Regexp.last_match(3)

          @assign_type = :variable
        elsif markup =~ SYNTAX_HASH
          @to = Regexp.last_match(1)
          # No longer checking there is hash access as it's mandatory in the Regex
          @from = Liquid::Expression.parse(Regexp.last_match(4))
          @keys = parse_raw_keys(Regexp.last_match(3))
          @rest_of_markup = Regexp.last_match(5)

          @assign_type = :hash
        else
          raise Liquid::SyntaxError, 'Invalid syntax for function tag'
        end

        @attributes = {}
        @rest_of_markup.scan(::PlatformosCheck::Tags::Base::TAG_ATTRIBUTES) do |key, value|
          unless well_formed_object_access?(value)
            raise Liquid::SyntaxError,
                  'Invalid syntax for function tag, no spaces allowed when accessing array or hash.'
          end

          @attributes[key] = Liquid::Expression.parse(value)
        end
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [
            @node.from,
            @node.main_value
          ] + @node.attributes_expr.values
        end
      end
    end
  end
end
