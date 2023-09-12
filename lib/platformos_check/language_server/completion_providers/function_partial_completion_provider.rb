# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class FunctionPartialCompletionProvider < CompletionProvider
      include PartialCompletionProvider

      private

      def files
        @storage.platformos_app.partials
      end

      def regexp
        PARTIAL_FUNCTION
      end
    end
  end
end
