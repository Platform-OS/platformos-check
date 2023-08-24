# frozen_string_literal: true

module PlatformosCheck
  module Tags
    module BaseTagMethods
      SYNTAX = /(#{Liquid::QuotedFragment}+)(\s*(#{Liquid::QuotedFragment}+))?/o
      # this is Liquid::TagAttributes with the beginnig changed from \w+ to [\w-] to allow for
      # attributes like html-id: 10, which was identified as id: 10, but should be html-id: 10.
      # In other words - allow hyphens in key names.
      TAG_ATTRIBUTES = /([\w-]+)\s*:\s*((?-mix:(?-mix:"[^"]*"|'[^']*')|(?:[^\s,|'"]|(?-mix:"[^"]*"|'[^']*'))+))/
      BACKWARDS_COMPATIBILITY_KEYS = %w[method].freeze

      attr_reader :main_value, :attributes_expr, :value_expr

      protected

      def parse_markup(tag_name, markup)
        @remaining_markup = markup

        parse_main_value(tag_name, markup)
        parse_attributes(@remaining_markup)
      end

      def parse_main_value(tag_name, markup)
        raise Liquid::SyntaxError, "Invalid syntax for #{tag_name} tag" unless markup =~ syntax

        @main_value = Regexp.last_match(1)
        @remaining_markup = markup[Regexp.last_match.end(1)..-1] if @main_value

        @value_expr = @main_value ? Liquid::Expression.parse(@main_value) : nil
      end

      def parse_attributes(markup)
        @attributes_expr = {}

        markup.scan(TAG_ATTRIBUTES) do |key, value|
          unless well_formed_object_access?(value)
            raise Liquid::SyntaxError,
                  'Invalid syntax for function tag, no spaces allowed when accessing array or hash.'
          end

          @attributes_expr[key] = Liquid::Expression.parse(value)
        end
      end

      def well_formed_object_access?(representation)
        return false if /\[\z/.match?(representation.to_s)

        true
      end

      def syntax
        SYNTAX
      end
    end
  end
end
