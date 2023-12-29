# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Context < Base
      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          @node.attributes_expr.values
        end
      end
    end
  end
end
