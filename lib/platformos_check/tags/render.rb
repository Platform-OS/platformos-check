# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Render < Liquid::Tag
      SYNTAX = /
      (
        ## for {% render "snippet" %}
          #{Liquid::QuotedString}+ |
        ## for {% render block %}
        ## We require the variable # segment to be at the beginning of the
        ## string (with \A). This is to prevent code like {% render !foo! %}
        ## from parsing
        \A#{Liquid::VariableSegment}+
      )
      ## for {% render "snippet" with product as p %}
      ## or {% render "snippet" for products p %}
      (\s+(with|#{Liquid::Render::FOR})\s+(#{Liquid::QuotedFragment}+))?
        (\s+(?:as)\s+(#{Liquid::VariableSegment}+))?
        ## variables passed into the tag (e.g. {% render "snippet", var1: value1, var2: value2 %}
        ## are not matched by this regex and are handled by Liquid::Render.initialize
        /xo

      disable_tags "include"

      attr_reader :template_name_expr, :variable_name_expr, :attributes

      def initialize(tag_name, markup, options)
        super

        raise Liquid::SyntaxError, options[:locale].t("errors.syntax.render") unless markup =~ SYNTAX

        template_name = Regexp.last_match(1)
        with_or_for = Regexp.last_match(3)
        variable_name = Regexp.last_match(4)

        @alias_name = Regexp.last_match(6)
        @variable_name_expr = variable_name ? parse_expression(variable_name) : nil
        @template_name_expr = parse_expression(template_name)
        @for = (with_or_for == Liquid::Render::FOR)

        @attributes = {}
        markup.scan(Liquid::TagAttributes) do |key, value|
          @attributes[key] = parse_expression(value)
        end
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [
            @node.template_name_expr,
            @node.variable_name_expr
          ] + @node.attributes.values
        end
      end
    end
  end
end
