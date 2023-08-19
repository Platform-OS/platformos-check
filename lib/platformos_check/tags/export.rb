# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Export < Liquid::Tag
      SYNTAX = /\A([\w-]+[\s,]*[\w\s,]*)\s*(namespace:\s*(.+))?\z/

      def initialize(tag_name, markup, options)
        super
        raise Liquid::SyntaxError, "Syntax Error in 'export' - Valid syntax: export [var1], [var2], ..., namespace: [namespace]" unless markup =~ SYNTAX

        @variables = Regexp.last_match(1).split(',')
        @namespace = Liquid::Expression.parse(Regexp.last_match(3)&.strip)
      end
    end
  end
end
