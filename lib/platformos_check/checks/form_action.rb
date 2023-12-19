# frozen_string_literal: true

module PlatformosCheck
  class FormAction < HtmlCheck
    severity :error
    categories :html
    doc docs_url(__FILE__)

    def on_form(node)
      action = node.attributes["action"]&.strip
      return if action.start_with?('/', '{{')

      add_offense("Use action=\"/#{action}\" (start with /) to ensure the form can be submitted multiple times in case of validation errors", node:)
    end
  end
end
