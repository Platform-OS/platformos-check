# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class IncludePartialCompletionProvider < CompletionProvider
      include PartialCompletionProvider

      private

      def files
        @storage.platformos_app.partials
      end

      def regexp
        PARTIAL_INCLUDE
      end
    end
  end
end
