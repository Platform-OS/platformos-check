# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Base < Liquid::Tag
      include BaseTagMethods

      def initialize(tag_name, markup, parse_context)
        super
        parse_markup(tag_name, markup)
      end
    end
  end
end
