# frozen_string_literal: true

module PlatformosCheck
  class HtmlParsingError < HtmlCheck
    severity :error
    category :html
    doc docs_url(__FILE__)

    def on_parse_error(exception, platformos_app_file)
      add_offense("HTML in this template can not be parsed: #{exception.message}", platformos_app_file:)
    end
  end
end
