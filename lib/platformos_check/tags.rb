# frozen_string_literal: true

module PlatformosCheck
  module Tags
    # Copied tags parsing code from storefront-renderer

    class ContentFor < BaseBlock; end

    class Yield < Base; end

    class IncludeForm < Base
      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [
            @node.main_value
          ] + @node.attributes_expr.values
        end
      end
    end

    class << self
      attr_writer :register_tags

      def register_tags?
        @register_tags
      end

      def register_tag(name, klass)
        Liquid::Environment.default.register_tag(name, klass)
      end

      def register_tags!
        return if !register_tags? || (defined?(@registered_tags) && @registered_tags)

        @registered_tags = true
        register_tag('background', Background)
        register_tag('cache', Cache)
        register_tag('content_for', ContentFor)
        register_tag('context', Context)
        register_tag('context_rc', Context)
        register_tag('export', Export)
        register_tag('form', Form)
        register_tag('function', Function)
        register_tag('graphql', Graphql)
        register_tag('hash_assign', HashAssign)
        register_tag('include_form', IncludeForm)
        register_tag('log', Log)
        register_tag('parse_json', ParseJson)
        register_tag('print', Print)
        register_tag('redirect_to', RedirectTo)
        register_tag('render', Render)
        register_tag('response_headers', ResponseHeaders)
        register_tag('response_status', ResponseStatus)
        register_tag('return', Return)
        register_tag('rollback', Rollback)
        register_tag('session', Session)
        register_tag('sign_in', SignIn)
        register_tag('spam_protection', SpamProtection)
        register_tag('theme_render', ThemeRender)
        register_tag('theme_render_rc', ThemeRender)
        register_tag('transaction', Transaction)
        register_tag('try', Try)
        register_tag('try_rc', Try)
        register_tag('yield', Yield)
      end
    end
    self.register_tags = true
  end
end
