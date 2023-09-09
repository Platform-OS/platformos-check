# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class BackgroundDocumentLinkProvider < DocumentLinkProvider
      @partial_regexp = PARTIAL_BACKGROUND
      @app_file_type = :partials
      @default_dir = 'lib'
      @default_extension = '.liquid'
    end
  end
end
