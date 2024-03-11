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

    def initialize(ignore_missing: [])
      @ignore_missing = ignore_missing
    end

    def on_include(node)
      partial = node.value.template_name_expr
      return unless partial.is_a?(String)

      add_missing_template_offense(partial, file_type: PartialFile, node:)
    end

    def on_render(node)
      partial = node.value.template_name_expr
      return unless partial.is_a?(String)

      add_missing_template_offense(partial, file_type: PartialFile, node:)
    end

    def on_background(node)
      partial = node.value.partial_name
      return unless partial.is_a?(String)

      add_missing_template_offense(partial, file_type: PartialFile, node:)
    end

    def on_function(node)
      partial = node.value.from
      return unless partial.is_a?(String)

      add_missing_template_offense(partial, file_type: PartialFile, node:)
    end

    def on_graphql(node)
      return if node.value.inline_query

      path = node.value.partial_name
      return unless path.is_a?(String)

      add_missing_template_offense(path, file_type: GraphqlFile, node:)
    end

    private

    def ignore?(path)
      all_ignored_patterns.any? { |pattern| File.fnmatch?(pattern, path) }
    end

    def all_ignored_patterns
      @all_ignored_patterns ||= @ignore_missing + ignored_patterns
    end

    def add_missing_template_offense(path, file_type:, node:)
      return if ignore?(path)

      file = platformos_app.grouped_files[file_type][path]

      return add_offense("'#{path}' is missing", node:) if file.nil?
      return add_offense("'#{path}' is blank", node:) if file.source.strip == ''

      nil
    end
  end
end
