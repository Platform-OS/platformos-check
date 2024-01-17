# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class DocumentLinkProvider
      include RegexHelpers
      include PositionHelper
      include URIHelper

      DEFAULT_LANGUAGE = 'en'

      DefaultTranslationFile = Struct.new(:relative_path) do
        def relative_path
          Pathname.new(DEFAULT_LANGUAGE, "#{DEFAULT_LANGUAGE}.yml")
        end
      end

      class << self
        attr_accessor :partial_regexp, :app_file_type, :default_dir, :default_extension

        def all
          @all ||= []
        end

        def inherited(subclass)
          all << subclass
        end
      end

      def initialize(storage = InMemoryStorage.new)
        @storage = storage
      end

      def app_file_type
        self.class.app_file_type
      end

      def default_dir
        self.class.default_dir
      end

      def default_extension
        self.class.default_extension
      end

      def partial_regexp
        self.class.partial_regexp
      end

      def document_links(buffer, platformos_app)
        matches(buffer, partial_regexp).map do |match|
          start_row, start_column = start_coordinates(buffer, match)

          end_row, end_column = end_coordinates(buffer, match)

          {
            target: file_link(match, platformos_app),
            range: {
              start: {
                line: start_row,
                character: start_column
              },
              end: {
                line: end_row,
                character: end_column
              }
            }
          }
        end
      end

      def start_coordinates(buffer, match)
        from_index_to_row_column(
          buffer,
          match.begin(:partial)
        )
      end

      def end_coordinates(buffer, match)
        from_index_to_row_column(
          buffer,
          match.end(:partial)
        )
      end

      def file_link(match, platformos_app)
        partial = match[:partial]
        relative_path = platformos_app.send(app_file_type).detect { |f| f.name == partial }&.relative_path
        relative_path ||= default_relative_path(partial)

        file_uri(@storage.path(relative_path))
      end

      def translation_file_link(match, platformos_app)
        @current_best_fit = platformos_app.translations.first || DefaultTranslationFile.new
        @current_best_fit_level = 0
        array_of_translation_components = translation_components_for_match(match)
        platformos_app.translations.each do |translation_file|
          array_of_translation_components.each do |translation_components|
            exact_match_level = translation_components.size
            component_result = translation_file.content[DEFAULT_LANGUAGE]
            next if component_result.nil?

            i = 0
            while i < exact_match_level
              component_result = yaml(component_result, translation_components[i])

              break if component_result.nil?

              i += 1
              if i > @current_best_fit_level
                @current_best_fit = translation_file
                @current_best_fit_level = i
              end

              break unless component_result.is_a?(Hash)
            end
          end
        end

        file_uri(@storage.path(@current_best_fit&.relative_path))
      end

      def translation_components_for_match(match)
        raise NotImplementedError
      end

      def yaml(component_result, component)
        component_result[component]
      end

      def default_relative_path(partial)
        return Pathname.new("app/#{default_dir}/#{partial}#{default_extension}") unless partial.start_with?('modules/')

        partial_components = partial.split(File::SEPARATOR)
        module_prefix = partial_components.shift(2).join(File::SEPARATOR)
        partial_without_module = partial_components.join(File::SEPARATOR)

        Pathname.new("#{module_prefix}/public/#{default_dir}/#{partial_without_module}#{default_extension}")
      end
    end
  end
end
