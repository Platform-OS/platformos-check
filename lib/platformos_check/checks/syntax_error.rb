# frozen_string_literal: true

module PlatformosCheck
  # Report Liquid syntax errors
  class SyntaxError < LiquidCheck
    severity :error
    category :liquid
    doc docs_url(__FILE__)

    def on_document(node)
      node.platformos_app_file.warnings.each do |warning|
        add_exception_as_offense(warning, platformos_app_file: node.platformos_app_file)
      end
    end

    def on_error(exception)
      add_exception_as_offense(exception, platformos_app_file: platformos_app[exception.template_name])
    end

    private

    def add_exception_as_offense(exception, platformos_app_file:)
      add_offense(
        exception.to_s(false).sub(/ in ".*"$/, ''),
        line_number: exception.line_number,
        markup: exception.markup_context&.sub(/^in "(.*)"$/, '\1'),
        platformos_app_file:
      )
    end
  end
end
