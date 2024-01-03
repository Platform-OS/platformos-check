# frozen_string_literal: true

module PlatformosCheck
  class FormAuthenticityToken < HtmlCheck
    severity :error
    categories :html
    doc docs_url(__FILE__)

    AUTHENTICITY_TOKEN_VALUE = /\A\s*{{\s*context\.authenticity_token\s*}}\s*\z/
    METHODS_TO_SKIP_AUTHENTICITY_TOKEN_CHECK = Set.new(['', 'get']).freeze

    def on_form(node)
      return if node.attributes['method'].nil?
      return if METHODS_TO_SKIP_AUTHENTICITY_TOKEN_CHECK.include?(node.attributes['method'].downcase.strip)

      authenticity_toke_inputs = node.children.select { |c| c.name == 'input' && c.attributes['name'] == 'authenticity_token' && c.attributes['value']&.match?(AUTHENTICITY_TOKEN_VALUE) }
      return if authenticity_toke_inputs.size == 1
      return add_offense('Duplicated authenticity_token inputs', node:) if authenticity_toke_inputs.size > 1

      add_offense('Missing authenticity_token input <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">', node:) do |corrector|
        corrector.insert_after(node, "\n<input type=\"hidden\" name=\"authenticity_token\" value=\"{{ context.authenticity_token }}\">")
      end
    end
  end
end
