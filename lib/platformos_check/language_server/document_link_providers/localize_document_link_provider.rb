# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class LocalizeDocumentLinkProvider < DocumentLinkProvider
      @partial_regexp = LOCALIZE_FILTER
      @app_file_type = :translations
      @default_dir = 'translations'
      @default_extension = '.yml'

      def file_link(match, platformos_app)
        translation_file_link(match, platformos_app)
      end

      def translation_components_for_match(match)
        key = match[:key].split('.')
        [
          %w[time formats] + key,
          %w[date formats] + key
        ]
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
