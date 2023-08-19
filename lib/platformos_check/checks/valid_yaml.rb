# frozen_string_literal: true

module PlatformosCheck
  class ValidYaml < YamlCheck
    severity :error
    category :yaml
    doc docs_url(__FILE__)

    def on_file(file)
      return unless file.parse_error

      message = file.parse_error
      add_offense(message, platformos_app_file: file)
    end
  end
end
