# frozen_string_literal: true

module PlatformosCheck
  # Report Liquid syntax errors
  class SyntaxError < LiquidCheck
    severity :error
    category :liquid
    doc docs_url(__FILE__)

    def on_document(node)
      node.app_file.warnings.each do |warning|
        add_exception_as_offense(warning, app_file: node.app_file)
      end
    end

    def on_error(exception)
      add_exception_as_offense(exception, app_file: platformos_app[exception.template_name])
    end

    private

    def add_exception_as_offense(exception, app_file:)
      add_offense(
        exception.to_s(false).sub(/ in ".*"$/, ''),
        line_number: exception.line_number,
        markup: exception.markup_context&.sub(/^in "(.*)"$/, '\1'),
        app_file:
      )
    end
  end
end
