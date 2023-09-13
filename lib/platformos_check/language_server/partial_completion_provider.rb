# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    module PartialCompletionProvider
      def completions(context)
        content = context.buffer.lines[context.line]
        cursor = context.col
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

        return false unless match.begin(:partial) <= cursor && cursor <= match.end(:partial)

        @file_name = match[:partial][0, cursor - match.begin(:partial)]
        true
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
          kind: CompletionItemKinds::SNIPPET,
          detail: file.source
        }
      end
    end
  end
end
