# frozen_string_literal: true

module PlatformosCheck
  class UndefinedObject < LiquidCheck
    category :liquid
    doc docs_url(__FILE__)
    severity :error

    class TemplateInfo
      def initialize(app_file: nil)
        @all_variable_lookups = {}
        @all_assigns = {}
        @all_captures = {}
        @all_forloops = {}
        @all_renders = {}
        @app_file = app_file
      end

      attr_reader :all_assigns, :all_captures, :all_forloops, :app_file

      def add_render(name:, node:)
        @all_renders[name] = node
      end

      def add_variable_lookup(name:, node:)
        parent = node
        line_number = nil
        loop do
          line_number = parent.line_number
          parent = parent.parent
          break unless line_number.nil? && parent
        end
        key = [name, line_number]
        @all_variable_lookups[key] = node
      end

      def all_variables
        all_assigns.keys + all_captures.keys + all_forloops.keys
      end

      def each_partial
        @all_renders.each do |(name, info)|
          yield [name, info]
        end
      end

      def each_variable_lookup(unique_keys = false)
        seen = Set.new
        @all_variable_lookups.each do |(key, info)|
          name, _line_number = key

          next if unique_keys && seen.include?(name)

          seen << name

          yield [key, info]
        end
      end
    end

    def initialize(config_type: :default, exclude_partials: true)
      @config_type = config_type
      @exclude_partials = exclude_partials
      @files = {}
    end

    def on_document(node)
      return if ignore?(node)

      @files[node.platformos_app_file.name] = TemplateInfo.new(app_file: node.platformos_app_file)
    end

    def on_assign(node)
      return if ignore?(node)

      @files[node.platformos_app_file.name].all_assigns[node.value.to] = node
    end

    def on_capture(node)
      return if ignore?(node)

      @files[node.platformos_app_file.name].all_captures[node.value.instance_variable_get(:@to)] = node
    end

    def on_parse_json(node)
      return if ignore?(node)

      @files[node.platformos_app_file.name].all_captures[node.value.to] = node
    end

    def on_for(node)
      return if ignore?(node)

      @files[node.platformos_app_file.name].all_forloops[node.value.variable_name] = node
    end

    def on_include(_node)
      # NOOP: we purposely do nothing on `include` since it is deprecated
      #   https://shopify.dev/docs/platformos_apps/liquid/reference/tags/deprecated-tags#include
    end

    def on_render(node)
      return if ignore?(node)
      return unless node.value.template_name_expr.is_a?(String)

      partial_name = node.value.template_name_expr
      @files[node.platformos_app_file.name].add_render(
        name: partial_name,
        node:
      )
    end

    def on_function(node)
      return if ignore?(node)

      name = node.value.from.is_a?(String) ? node.value.from : node.value.from.name
      @files[node.platformos_app_file.name].add_render(
        name:,
        node:
      )

      @files[node.platformos_app_file.name].all_assigns[node.value.to] = node
    end

    def on_graphql(node)
      return if ignore?(node)

      @files[node.platformos_app_file.name].all_assigns[node.value.to] = node
    end

    def on_variable_lookup(node)
      return if ignore?(node)

      @files[node.platformos_app_file.name].add_variable_lookup(
        name: node.value.name,
        node:
      )
    end

    def on_end
      all_global_objects = PlatformosCheck::ShopifyLiquid::Object.labels
      all_global_objects.freeze

      shopify_plus_objects = PlatformosCheck::ShopifyLiquid::Object.plus_labels
      shopify_plus_objects.freeze

      platformos_app_app_extension_objects = PlatformosCheck::ShopifyLiquid::Object.platformos_app_app_extension_labels
      platformos_app_app_extension_objects.freeze

      each_template do |(_name, info)|
        if info.app_file.notification?
          # NOTE: `data` comes from graphql for notifications
          check_object(info, all_global_objects + ['data'])
        elsif config_type == :platformos_app_app_extension
          check_object(info, all_global_objects + platformos_app_app_extension_objects)
        else
          check_object(info, all_global_objects)
        end
      end
    end

    private

    attr_reader :config_type

    def ignore?(node)
      @exclude_partials && node.platformos_app_file.partial?
    end

    def each_template
      @files.each do |(name, info)|
        next if info.app_file.partial?

        yield [name, info]
      end
    end

    def check_object(info, all_global_objects, render_node = nil, visited_partials = Set.new)
      check_undefined(info, all_global_objects, render_node)

      info.each_partial do |(partial_name, node)|
        partial_info = @files[partial_name]
        next unless partial_info # NOTE: undefined partial

        partial_variables = node.value.attributes.keys +
                            [node.value.instance_variable_get(:@alias_name)]
        unless visited_partials.include?(partial_name)
          visited_partials << partial_name
          check_object(partial_info, all_global_objects + partial_variables, node, visited_partials)
        end
      end
    end

    def check_undefined(info, all_global_objects, render_node)
      all_variables = info.all_variables

      info.each_variable_lookup(!!render_node) do |(key, node)|
        name, line_number = key
        next if all_variables.include?(name)
        next if all_global_objects.include?(name)

        node = node.parent
        node = node.parent if %i[condition variable_lookup].include?(node.type_name)

        next if node.variable? && node.filters.any? { |(filter_name)| filter_name == "default" }

        if render_node
          add_offense("Missing argument `#{name}`", node: render_node)
        else
          add_offense("Undefined object `#{name}`", node:, line_number:)
        end
      end
    end
  end
end
