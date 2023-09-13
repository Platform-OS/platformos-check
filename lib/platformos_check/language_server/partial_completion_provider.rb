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
          .map { |x| file_to_completion(x, context) }
      end

      private

      def cursor_on_quoted_argument?(content, cursor)
        @match = content.match(regexp)
        return false if @match.nil?

        return false unless @match.begin(:partial) <= cursor && cursor <= @match.end(:partial)

        @file_name = @match[:partial][0, cursor - @match.begin(:partial)]
        true
      end

      def files
        raise NotImplementedError
      end

      def regexp
        raise NotImplementedError
      end

      def file_to_completion(file, context)
        {
          label: file.name,
          kind: CompletionItemKinds::TEXT,
          detail: file.source,
          textEdit: {
            newText: file.name,
            insert: {
              start: {
                line: context.line,
                character: @match.begin(:partial)
              },
              end: {
                line: context.line,
                character: @match.end(:partial)
              }
            },
            replace: {
              start: {
                line: context.line,
                character: @match.begin(:partial)
              },
              end: {
                line: context.line,
                character: @match.end(:partial)
              }
            }
          }
        }
      end
    end
  end
end
