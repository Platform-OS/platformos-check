# frozen_string_literal: true

require "pp"
require "timeout"

module PlatformosCheck
  class Checks < Array
    CHECK_METHOD_TIMEOUT = 5 # sec

    def call(method, *)
      each do |check|
        call_check_method(check, method, *)
      end
    end

    def disableable
      @disableable ||= self.class.new(select(&:can_disable?))
    end

    def whole_platformos_app
      @whole_platformos_app ||= self.class.new(select(&:whole_platformos_app?))
    end

    def single_file
      @single_file ||= self.class.new(select(&:single_file?))
    end

    def single_file_end_dependencies(app_file)
      map do |check|
        check.respond_to?(:single_file_end_dependencies) ? check.single_file_end_dependencies(app_file) : []
      end.flatten.compact.uniq
    end

    private

    def call_check_method(check, method, *args)
      return unless check.respond_to?(method) && !check.ignored?

      # If you want to use binding.pry in unit tests, define the
      # PLATFORMOS_CHECK_DEBUG environment variable. e.g.
      #
      #   $ export PLATFORMOS_CHECK_DEBUG=true
      #   $ bundle exec rake tests:in_memory
      #
      if ENV['PLATFORMOS_CHECK_DEBUG']
        check.send(method, *args)
      else
        Timeout.timeout(CHECK_METHOD_TIMEOUT) do
          check.send(method, *args)
        end
      end
    rescue Liquid::Error, PlatformosCheckError
      raise
    rescue StandardError => e
      node = args.first
      app_file = node.respond_to?(:app_file) ? node.app_file.relative_path : "?"
      markup = node.respond_to?(:markup) ? node.markup : ""
      node_class = node.respond_to?(:value) ? node.value.class : "?"
      line_number = node.respond_to?(:line_number) ? node.line_number : "?"

      PlatformosCheck.bug(<<~EOS)
        Exception while running `#{check.code_name}##{method}`:
        ```
        #{e.class}: #{e.message}
          #{e.backtrace.join("\n  ")}
        ```

        Platformos App File: `#{app_file}`
        Node: `#{node_class}`
        Markup:
        ```
        #{markup}
        ```
        Line number: #{line_number}
        Check options: `#{check.options.pretty_inspect}`
      EOS
    end
  end
end
