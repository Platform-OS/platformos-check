# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Base < Liquid::Tag
      SYNTAX = /(#{Liquid::QuotedFragment}+)(\s*(#{Liquid::QuotedFragment}+))?/o
      # this is Liquid::TagAttributes with the beginnig changed from \w+ to [\w-] to allow for
      # attributes like html-id: 10, which was identified as id: 10, but should be html-id: 10.
      # In other words - allow hyphens in key names.
      TAG_ATTRIBUTES = /([\w-]+)\s*:\s*((?-mix:(?-mix:"[^"]*"|'[^']*')|(?:[^\s,|'"]|(?-mix:"[^"]*"|'[^']*'))+))/
      BACKWARDS_COMPATIBILITY_KEYS = %w[method].freeze

      def initialize(tag_name, markup, parse_context)
        super
        parse_markup(tag_name, markup)
      end

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
    # Copied tags parsing code from storefront-renderer

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

    class Background < Base
      PARTIAL_SYNTAX = /(#{Liquid::VariableSignature}+)\s*=\s*(.*)\s*/om
      CLOSE_TAG_SYNTAX = /\A(.*)(?-mix:\{%-?)\s*(\w+)\s*(.*)?(?-mix:%\})\z/m # based on Liquid::Raw::FullTokenPossiblyInvalid

      def initialize(tag_name, markup, options)
        if markup =~ PARTIAL_SYNTAX
          super
          @to = Regexp.last_match(1)
          @partial_syntax = true

          after_assign_markup = Regexp.last_match(2).split('|')
          parse_markup(tag_name, after_assign_markup.shift)
          after_assign_markup.unshift(@to)
          @from = Liquid::Variable.new(after_assign_markup.join('|'), options)
        else
          @partial_syntax = false
          parse_markup(tag_name, markup)
          super
        end
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
    end

    class Function < Liquid::Tag; end

    class Log < Liquid::Tag; end

    class << self
      attr_writer :register_tags

      def register_tags?
        @register_tags
      end

      def register_tag(name, klass)
        Liquid::Template.register_tag(name, klass)
      end

      def register_tags!
        return if !register_tags? || (defined?(@registered_tags) && @registered_tags)

        @registered_tags = true
        register_tag('render', Render)
        register_tag('log', Log)
        register_tag('background', Background)
        register_tag('function', Function)
      end
    end
    self.register_tags = true
  end
end
