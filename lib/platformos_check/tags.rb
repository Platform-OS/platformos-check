# frozen_string_literal: true

module PlatformosCheck
  module Tags
    # Copied tags parsing code from storefront-renderer

    class Section < Liquid::Tag
      SYNTAX = /\A\s*(?<section_name>#{Liquid::QuotedString})\s*\z/o

      attr_reader :section_name

      def initialize(tag_name, markup, options)
        super

        match = markup.match(SYNTAX)
        unless match
          raise(
            Liquid::SyntaxError,
            "Error in tag 'section' - Valid syntax: section '[type]'"
          )
        end
        @section_name = match[:section_name].tr(%('"), '')
        @section_name.chomp!(".liquid") if @section_name.end_with?(".liquid")
      end
    end

    class Sections < Liquid::Tag
      SYNTAX = /\A\s*(?<sections_name>#{Liquid::QuotedString})\s*\z/o

      attr_reader :sections_name

      def initialize(tag_name, markup, options)
        super

        match = markup.match(SYNTAX)
        unless match
          raise(
            Liquid::SyntaxError,
            "Error in tag 'sections' - Valid syntax: sections '[type]'"
          )
        end
        @sections_name = match[:sections_name].tr(%('"), '')
        @sections_name.chomp!(".liquid") if @sections_name.end_with?(".liquid")
      end
    end

    class Paginate < Liquid::Block
      SYNTAX = /(?<liquid_variable_name>#{Liquid::QuotedFragment})\s*((?<by>by)\s*(?<page_size>#{Liquid::QuotedFragment}))?/

      attr_reader :page_size

      def initialize(tag_name, markup, options)
        super
        raise(Liquid::SyntaxError, "in tag 'paginate' - Valid syntax: paginate [collection] by number") unless (matches = markup.match(SYNTAX))

        @liquid_variable_name = matches[:liquid_variable_name]
        @page_size = parse_expression(matches[:page_size])
        @window_size = nil # determines how many pagination links are shown

        @liquid_variable_count_expr = parse_expression("#{@liquid_variable_name}_count")

        var_parts = @liquid_variable_name.rpartition('.')
        @source_drop_expr = parse_expression(var_parts[0].empty? ? var_parts.last : var_parts.first)
        @method_name = var_parts.last.to_sym

        markup.scan(Liquid::TagAttributes) do |key, value|
          case key
          when 'window_size'
            @window_size = value.to_i
          end
        end
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          super + [@node.page_size]
        end
      end
    end

    class Layout < Liquid::Tag
      SYNTAX = /(?<layout>#{Liquid::QuotedFragment})/

      NO_LAYOUT_KEYS = %w[false nil none].freeze

      attr_reader :layout_expr

      def initialize(tag_name, markup, tokens)
        super
        match = markup.match(SYNTAX)
        unless match
          raise(
            Liquid::SyntaxError,
            "in 'layout' - Valid syntax: layout (none|[layout_name])"
          )
        end
        layout_markup = match[:layout]
        @layout_expr = if NO_LAYOUT_KEYS.include?(layout_markup.downcase)
                         false
                       else
                         parse_expression(layout_markup)
                       end
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [@node.layout_expr]
        end
      end
    end

    class ContentFor < BaseBlock; end

    class Yield < Base; end

    class Style < Liquid::Block; end

    class IncludeForm < Liquid::Tag; end

    class Schema < Liquid::Raw; end

    class Javascript < Liquid::Raw; end

    class Stylesheet < Liquid::Raw; end

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
        register_tag('form', Form)
        register_tag('include_form', IncludeForm)
        register_tag('layout', Layout)
        register_tag('render', Render)
        register_tag('paginate', Paginate)
        register_tag('section', Section)
        register_tag('sections', Sections)
        register_tag('style', Style)
        register_tag('log', Log)
        register_tag('cache', Cache)
        register_tag('print', Print)
        register_tag('parse_json', ParseJson)
        register_tag('export', Export)
        register_tag('return', Return)
        register_tag('redirect_to', RedirectTo)
        register_tag('response_headers', ResponseHeaders)
        register_tag('response_status', ResponseStatus)
        register_tag('hash_assign', HashAssign)
        register_tag('background', Background)
        register_tag('content_for', ContentFor)
        register_tag('session', Session)
        register_tag('yield', Yield)
        register_tag('graphql', Graphql)
        register_tag('function', Function)
        register_tag('schema', Schema)
        register_tag('javascript', Javascript)
        register_tag('stylesheet', Stylesheet)
      end
    end
    self.register_tags = true
  end
end
