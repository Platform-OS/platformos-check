# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    class ObjectCompletionProvider < CompletionProvider
      def completions(context)
        content = context.content

        return [] if content.nil?
        return [] unless (variable_lookup = VariableLookupFinder.lookup(context))
        return [] unless variable_lookup.lookups.empty?
        return [] if content[context.cursor - 1] == "."


        current_file_type = file_type(find_file(context))

        PlatformosLiquid::SourceIndex
          .objects
          .select(&:global?)
          .select { |object| object.app_file_type ? object.app_file_type == current_file_type : true }
          .select { |object| object.name.start_with?(partial(variable_lookup)) }
          .map { |object| object_to_completion(object) }
      end

      def partial(variable_lookup)
        variable_lookup.name || ''
      end

      private

      def object_to_completion(object)
        content = PlatformosLiquid::Documentation.render_doc(object)

        {
          label: object.name,
          kind: CompletionItemKinds::VARIABLE,
          **format_hash(object),
          **doc_hash(content)
        }
      end

      def find_file(context)
        @storage.platformos_app
          .grouped_files
          .values
          .map(&:values)
          .flatten
          .find { |app_file| app_file.relative_path.to_s == context.relative_path }
      end

      def file_type(app_file)
        StringHelpers.underscore(StringHelpers.demodulize(app_file.class.name)).gsub(/_file$/, '')
      end
    end
  end
end
