# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Doc < Liquid::Block
      def initialize(tag_name, markup, options)
        super
        raise Liquid::SyntaxError, "Syntax Error in 'doc' - doc tag does not accept any parameters" unless markup.strip.empty?
      end
    end
  end
end
