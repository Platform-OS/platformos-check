# frozen_string_literal: true

module PlatformosCheck
  class FormAuthenticityToken < HtmlCheck
    severity :error
    categories :html
    doc docs_url(__FILE__)

    AUTHENTICITY_TOKEN_VALUE = /\A\s*{{\s*context\.authenticity_token\s*}}\s*\z/

    def on_form(node)
      return if method_is_get(node.attributes['method'])
      return unless action_is_relative_url(node.attributes['action'])

      authenticity_toke_inputs = node.children.select { |c| c.name == 'input' && c.attributes['name'] == 'authenticity_token' && c.attributes['value']&.match?(AUTHENTICITY_TOKEN_VALUE) }
      return if authenticity_toke_inputs.size == 1
      return add_offense('Duplicated authenticity_token inputs', node:) if authenticity_toke_inputs.size > 1

      add_offense('Missing authenticity_token input <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">', node:) do |corrector|
        corrector.insert_after(node, "\n<input type=\"hidden\" name=\"authenticity_token\" value=\"{{ context.authenticity_token }}\">")
      end
    end

    protected

    def method_is_get(method)
      return true if method.nil?

      method = method.downcase.strip
      return true if method == ''

      method == 'get'
    end

    def action_is_relative_url(action)
      return true if action.nil?

      action.lstrip[0] == '/'
    end
  end
end
