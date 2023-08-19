# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class BaseBlock < Liquid::Block
      include BaseTagMethods

      def initialize(tag_name, markup, options)
        super
        parse_markup(tag_name, markup)
      end
    end
  end
end
