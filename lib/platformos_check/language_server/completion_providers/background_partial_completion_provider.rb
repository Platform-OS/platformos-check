# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class BackgroundPartialCompletionProvider < CompletionProvider
      include PartialCompletionProvider

      private

      def files
        @storage.platformos_app.partials
      end

      def regexp
        PARTIAL_BACKGROUND
      end
    end
  end
end
