# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    module PartialCompletionProvider
      def completions(context)
        content = context.content
        cursor = context.cursor
        @file_name = nil

        return [] if content.nil?
        return [] unless cursor_on_quoted_argument?(content, cursor)

        files
          .select { |x| x.name.start_with?(@file_name) }
          .map { |x| file_to_completion(x) }
      end

      private

      def cursor_on_quoted_argument?(content, cursor)
        match = content.match(regexp)
        return false if match.nil?

        @file_name = match[:partial] if match.begin(:partial) <= cursor && cursor <= match.end(:partial)
        !@file_name.nil?
      end

      def files
        raise NotImplementedError
      end

      def regexp
        raise NotImplementedError
      end

      def file_to_completion(file)
        {
          label: file.name,
          kind: CompletionItemKinds::SNIPPET
        }
      end
    end
  end
end
