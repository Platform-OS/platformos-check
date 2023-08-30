# frozen_string_literal: true

module PlatformosCheck
  class TemplateLength < LiquidCheck
    severity :suggestion
    category :liquid
    doc docs_url(__FILE__)

    def initialize(max_length: 600)
      @max_length = max_length
    end

    def after_document(node)
      lines = node.app_file.source.count("\n")
      return unless lines > @max_length

      add_offense("Template has too many lines [#{lines}/#{@max_length}]", app_file: node.app_file)
    end
  end
end
