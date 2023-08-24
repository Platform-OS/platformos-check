# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Try < BaseBlock
      SYNTAX = /(#{::Liquid::VariableSignature}+)/o

      attr_reader :error_var

      def initialize(tag_name, markup, options)
        super
        @try_block = new_body
        @catch_block = nil
        @ensure_block = nil
      end

      def parse(tokens)
        if parse_body(@try_block, tokens)
          parse_body(@catch_block, tokens) if @catch_block
          parse_body(@ensure_block, tokens) if @ensure_block
        end
        if blank?
          @try_block.remove_blank_strings
          @catch_block&.remove_blank_strings
          @ensure_block&.remove_blank_strings
        end
        @try_block.freeze
        @catch_block&.freeze
        @ensure_block&.freeze
      end

      def nodelist
        [@try_block, @catch_block, @ensure_block].compact
      end

      def unknown_tag(tag, markup, tokens)
        if tag == 'catch'
          raise Liquid::SyntaxError, "Syntax Error in 'try' - Valid syntax: try ... catch [var] ... endtry" unless markup =~ SYNTAX

          @error_var = Regexp.last_match(1)

          @catch_block = new_body
        elsif tag == 'ensure'
          @ensure_block = new_body
        else
          super
        end
      end

      def parse_main_value(tag_name, markup); end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          @node.nodelist
        end
      end
    end
  end
end
