# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class DocumentLinkProvider
      include RegexHelpers
      include PositionHelper
      include URIHelper

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
          start_row, start_column = from_index_to_row_column(
            buffer,
            match.begin(:partial)
          )

          end_row, end_column = from_index_to_row_column(
            buffer,
            match.end(:partial)
          )

          {
            target: file_link(match[:partial], platformos_app),
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

      def file_link(partial, platformos_app)
        relative_path = platformos_app.send(app_file_type).detect { |f| f.name == partial }&.relative_path
        relative_path ||= default_relative_path(partial)

        file_uri(@storage.path(relative_path))
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
