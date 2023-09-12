# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class RenderPartialCompletionProvider < CompletionProvider
      include PartialCompletionProvider

      private

      def files
        @storage.platformos_app.partials
      end

      def regexp
        PARTIAL_RENDER
      end
    end
  end
end
