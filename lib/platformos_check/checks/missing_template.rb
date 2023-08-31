# frozen_string_literal: true

module PlatformosCheck
  # Reports missing include/render/section liquid file
  class MissingTemplate < LiquidCheck
    class MissingFileCorrection
      def initialize(path:, directory:, extension:)
        @path = path
        @directory = directory
        @extension = extension
      end

      def full_relative_path
        @full_relative_path ||= module? ? module_path : app_path
      end

      private

      attr_reader :path, :directory, :extension

      def app_path
        ['app', directory, "#{path}#{extension}"].join(File::SEPARATOR)
      end

      def module_path
        path.split(File::SEPARATOR).insert(2, "public#{File::SEPARATOR}#{directory}").join(File::SEPARATOR) + extension
      end

      def module?
        path.start_with?('modules/')
      end
    end

    severity :suggestion
    category :liquid
    doc docs_url(__FILE__)
    single_file false

    def initialize(ignore_missing: [])
      @ignore_missing = ignore_missing
    end

    def on_include(node)
      partial = node.value.template_name_expr
      return unless partial.is_a?(String)

      add_missing_partial_offense(partial, node:)
    end

    def on_render(node)
      partial = node.value.template_name_expr
      return unless partial.is_a?(String)

      add_missing_partial_offense(partial, node:)
    end

    def on_function(node)
      partial = node.value.from
      return unless partial.is_a?(String)

      add_missing_function_offense(partial, node:)
    end

    def on_graphql(node)
      return if node.value.inline_query

      graphql_partial = node.value.partial_name
      return unless graphql_partial.is_a?(String)

      add_missing_graphql_offense(graphql_partial, node:)
    end

    private

    def ignore?(path)
      all_ignored_patterns.any? { |pattern| File.fnmatch?(pattern, path) }
    end

    def all_ignored_patterns
      @all_ignored_patterns ||= @ignore_missing + ignored_patterns
    end

    def add_missing_partial_offense(path, node:)
      return if ignore?(path) || platformos_app.grouped_files[PartialFile][path]

      add_offense("'#{path}' is not found", node:) # do |corrector|
      # corrector.create_file(@platformos_app.storage, MissingFileCorrection.new(path:, directory: 'views/partials', extension: '.liquid').full_relative_path, "")
      # end
    end

    def add_missing_function_offense(path, node:)
      return if ignore?(path) || platformos_app.grouped_files[PartialFile][path]

      add_offense("'#{path}' is not found", node:) # do |corrector|
      # corrector.create_file(@platformos_app.storage, MissingFileCorrection.new(path:, directory: 'lib', extension: '.liquid').full_relative_path, "")
      # end
    end

    def add_missing_graphql_offense(path, node:)
      return if ignore?(path) || platformos_app.grouped_files[GraphqlFile][path]

      add_offense("'#{path}' is not found", node:) # do |corrector|
      # corrector.create_file(@platformos_app.storage, MissingFileCorrection.new(path:, directory: 'graphql', extension: '.graphql').full_relative_path, "")
      # end
    end
  end
end
