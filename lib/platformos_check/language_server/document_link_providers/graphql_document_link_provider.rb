# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class GraphqlDocumentLinkProvider < DocumentLinkProvider
      @partial_regexp = PARTIAL_GRAPHQL
      @app_file_type = :graphqls
      @default_dir = 'graphql'
      @default_extension = '.graphql'
    end
  end
end
