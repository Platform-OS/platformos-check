# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class ThemeRenderDocumentLinkProvider < DocumentLinkProvider
      @partial_regexp = PARTIAL_THEME_RENDER
      @app_file_type = :partials
      @default_dir = 'views/partials'
      @default_extension = '.liquid'

      def file_link(partial, platformos_app)
        relative_path = nil
        path_prefixes(platformos_app).each do |prefix|
          prefix ||= ''
          partial_with_prefix = (prefix.split(File::SEPARATOR) + [partial]).join(File::SEPARATOR)
          relative_path = platformos_app.send(app_file_type).detect { |f| f.name == partial_with_prefix }&.relative_path
          break if relative_path
        end

        relative_path ||= default_relative_path(partial)

        file_uri(@storage.path(relative_path))
      end

      private

      def path_prefixes(platformos_app)
        platformos_app.app_config.content['theme_search_paths'] || ['']
      rescue StandardError
        ['']
      end
    end
  end
end
