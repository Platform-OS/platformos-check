# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class FunctionDocumentLinkProvider < DocumentLinkProvider
      @partial_regexp = PARTIAL_FUNCTION
      @app_file_type = :partials
      @default_dir = 'lib'
      @default_extension = '.liquid'
    end
  end
end
