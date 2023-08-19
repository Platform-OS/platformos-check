# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class HashAssign < Base
      SYNTAX = /((\(?[\w\-.]\)?)+)(\[.+\])*\s*=\s*(\S.*)\s*/om
      KEYS = /[\w\-"'.]+/

      attr_reader :keys, :to, :from

      def initialize(tag_name, markup, options)
        super
        raise Liquid::SyntaxError, "Syntax Error in 'hash_assign' - Valid syntax: hash_assign hash[key] = value" unless markup =~ SYNTAX

        @to = Regexp.last_match(1)
        @from = Liquid::Variable.new(Regexp.last_match(4), options)
        raw_keys = Regexp.last_match(3)
        raise Liquid::SyntaxError, "Syntax Error in 'hash_assign' - Valid syntax: hash_assign hash[key] = value" unless raw_keys

        @keys = parse_raw_keys(raw_keys)
      end

      # raw_keys can be something like
      # "[item2][ item[0] ]['mich][ael']"
      def parse_raw_keys(raw_keys)
        nesting_level = 0
        keys = []
        current_key = ''
        in_double_quote = false
        in_single_quote = false
        raw_keys.each_char do |char|
          case char
          when '['
            if !in_double_quote && !in_single_quote
              nesting_level += 1
              current_key += char if nesting_level > 1
            else
              current_key += char
            end
          when ']'
            if !in_double_quote && !in_single_quote
              nesting_level -= 1
              if nesting_level.zero?
                keys << Liquid::Expression.parse(current_key)
                current_key = ''
              else
                current_key += char
              end
            else
              current_key += char
            end
          when '"'
            in_double_quote = !in_double_quote unless in_single_quote
            current_key += char
          when "'"
            in_single_quote = !in_single_quote unless in_double_quote
            current_key += char
          else
            current_key += char
          end
        end

        keys
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [
            @node.from
          ] + @node.keys
        end
      end
    end
  end
end
