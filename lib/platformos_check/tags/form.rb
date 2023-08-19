# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Form < BaseBlock
      def initialize(tag_name, markup, tokens)
        super
        @tag_name = tag_name
        @markup = markup
        @model_name = markup.scan(::Liquid::QuotedFragment).flatten.first
        # we want to allow {% form method: delete %}, but also {% form form, method: delete %}
        @model_name = 'form' if @model_name.nil? || @model_name == '' || @model_name[-1] == ':'
        parse_attributes(markup)
      end

      def parse_main_value(_tag_name, _markup); end
    end
  end
end
