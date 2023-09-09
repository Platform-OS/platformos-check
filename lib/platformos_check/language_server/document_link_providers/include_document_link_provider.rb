# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class IncludeDocumentLinkProvider < DocumentLinkProvider
      @partial_regexp = PARTIAL_INCLUDE
      @app_file_type = :partials
      @default_dir = 'views/partials'
      @default_extension = '.liquid'
    end
  end
end
