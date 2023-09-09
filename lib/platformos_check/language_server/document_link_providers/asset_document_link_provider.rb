# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class AssetDocumentLinkProvider < DocumentLinkProvider
      @partial_regexp = ASSET_INCLUDE
      @app_file_type = :assets
      @default_dir = 'assets'
    end
  end
end
