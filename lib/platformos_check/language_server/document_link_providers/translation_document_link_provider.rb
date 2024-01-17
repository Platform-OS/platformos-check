# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class TranslationDocumentLinkProvider < DocumentLinkProvider
      @partial_regexp = TRANSLATION_FILTER
      @app_file_type = :translations
      @default_dir = 'translations'
      @default_extension = '.yml'

      def file_link(match, platformos_app)
        translation_file_link(match, platformos_app)
      end

      def translation_components_for_match(match)
        translation_components = match[:key].split('.')
        translation_components = match[:scope].split('.') + translation_components if match[:scope]
        [translation_components]
      end

      def start_coordinates(buffer, match)
        from_index_to_row_column(
          buffer,
          match.begin(:key)
        )
      end

      def end_coordinates(buffer, match)
        from_index_to_row_column(
          buffer,
          match.end(:key)
        )
      end
    end
  end
end
