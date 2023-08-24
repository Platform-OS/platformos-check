# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class RedirectTo < Liquid::Tag
      attr_reader :var

      def initialize(tag_name, markup, options)
        super
        @var = Liquid::Variable.new(markup, options)
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [@node.var]
        end
      end
    end
  end
end
