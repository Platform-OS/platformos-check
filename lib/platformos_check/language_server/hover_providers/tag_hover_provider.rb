# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class TagHoverProvider < HoverProvider
      def completions(context)
        content = context.content

        return [] if content.nil?
        return [] unless can_complete?(context)

        partial = first_word(context.buffer.lines[context.line]) || ''
        PlatformosLiquid::SourceIndex.tags.select { |tag| tag.name.start_with?(partial) }
                                     .map { |tag| tag_to_completion(tag) }.first
      end

      def can_complete?(context)
        context.content.start_with?(Liquid::TagStart) && (cursor_on_first_word?(context.buffer.lines[context.line], context.col) || cursor_on_start_content?(context.buffer.lines[context.line], context.col, Liquid::TagStart))
      end

      private

      def tag_to_completion(tag)
        content = PlatformosLiquid::Documentation.tag_doc(tag.name)

        {
          contents: content,
          label: tag.name,
          kind: CompletionItemKinds::KEYWORD,
          **format_hash(tag),
          **doc_hash(content)
        }
      end
    end
  end
end
