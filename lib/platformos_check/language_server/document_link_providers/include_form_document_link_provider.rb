# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class IncludeFormDocumentLinkProvider < DocumentLinkProvider
      @partial_regexp = PARTIAL_INCLUDE_FORM
      @app_file_type = :forms
      @default_dir = 'forms'
      @default_extension = '.liquid'
    end
  end
end
