# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class GraphqlPartialCompletionProvider < CompletionProvider
      include PartialCompletionProvider

      private

      def files
        @storage.platformos_app.graphqls
      end

      def regexp
        PARTIAL_GRAPHQL
      end
    end
  end
end
