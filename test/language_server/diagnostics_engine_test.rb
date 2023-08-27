# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class DiagnosticsEngineTest < Minitest::Test
      include URIHelper

      def setup
        @messenger = MockMessenger.new
        @bridge = Bridge.new(@messenger)
        @storage = make_file_system_storage(
          "app/views/layouts/platformos_app.liquid" => "{% render 'a' %}{% render 'b' %}",
          "app/views/partials/a.liquid" => "{% if unclosed %}",
          "app/views/partials/b.liquid" => "{% if unclosed %}",
          "app/views/partials/c.liquid" => "",
          ".platformos-check.yml" => <<~YML
            extends: :nothing
            SyntaxError:
              enabled: true
            UnusedPartial:
              enabled: true
          YML
        )
        @engine = DiagnosticsEngine.new(@storage, @bridge)
      end

      def test_analyze_and_send_offenses_full_on_first_run_partial_second_run
        # On the first run, analyze the entire platformos_app
        analyze_and_send_offenses("app/views/layouts/platformos_app.liquid")

        # Expect diagnostics for all files
        assert_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/a.liquid", [:syntax]))
        assert_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/b.liquid", [:syntax]))
        assert_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/c.liquid", [:unused]))

        # Secretly correct all the files
        @storage.write("app/views/partials/a.liquid", "{% if unclosed %}{% endif %}")
        @storage.write("app/views/partials/b.liquid", "{% if unclosed %}{% endif %}")

        # Rerun analyze_and_send_offenses on a file
        @messenger.sent_messages.clear
        analyze_and_send_offenses("app/views/partials/a.liquid")

        # Expect empty diagnostics for the file that was fixed
        assert_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/a.liquid"))
        refute_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/b.liquid"))

        # Run it on the other file that was fixed
        analyze_and_send_offenses("app/views/partials/b.liquid")

        # Expect empty diagnostics for the other file that was fixed
        assert_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/a.liquid"))
      end

      def test_analyze_and_send_offenses_with_only_single_file
        # Only expect single file diagnostics for the file checked
        analyze_and_send_offenses("app/views/partials/a.liquid", only_single_file: true)

        assert_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/a.liquid", [:syntax]))
        refute_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/b.liquid", [:syntax]))
        refute_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/c.liquid", [:unused]))

        # whole platformos_app checks are ignored in this mode
        analyze_and_send_offenses("app/views/partials/c.liquid", only_single_file: true)

        refute_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/c.liquid", [:unused]))

        # Correct the file
        @storage.write("app/views/partials/a.liquid", "{% if unclosed %}{% endif %}")
        @storage.write("app/views/partials/b.liquid", "{% if unclosed %}{% endif %}")

        # Rerun analyze_and_send_offenses on a file
        @messenger.sent_messages.clear
        analyze_and_send_offenses("app/views/partials/a.liquid")

        # Expect empty diagnostics for the file that was fixed
        assert_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/a.liquid"))
        refute_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/b.liquid"))
        refute_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/c.liquid"))

        # Run it on the other file that was fixed
        analyze_and_send_offenses("app/views/partials/b.liquid")

        # Do not expect empty diagnostics for that file, diagnostics were never sent
        refute_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/b.liquid"))
      end

      # For when you want fast checks on change but slow changes on save
      def test_analyze_and_send_offenses_mixed_mode
        # Run a full platformos_app check on first run
        analyze_and_send_offenses("app/views/partials/a.liquid")

        assert_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/a.liquid", [:syntax]))
        assert_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/b.liquid", [:syntax]))
        assert_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/c.liquid", [:unused]))

        # Fix an error by typing code, but only run single file checks
        @messenger.sent_messages.clear
        @storage.write("app/views/partials/a.liquid", "{% if unclosed %}{% endif %}")
        analyze_and_send_offenses("app/views/partials/a.liquid", only_single_file: true)

        # Get updated diagnostics for that file, but not the untouched ones
        assert_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/a.liquid"))
        refute_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/c.liquid"))
        refute_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/c.liquid", [:unused]))

        # Fix the UnusedPartial error by typing
        @messenger.sent_messages.clear
        @storage.write("app/views/layouts/platformos_app.liquid", "{% render 'a' %}{% render 'b' %}{% render 'c' %}")
        analyze_and_send_offenses("app/views/layouts/platformos_app.liquid", only_single_file: true)

        # Don't expect empty or resent diagnostics for the fixed file
        refute_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/c.liquid"))
        refute_includes(@messenger.sent_messages, diagnostics_notification("app/views/partials/c.liquid", [:unused]))

        # Hit "save", run whole platformos_app checks. Remove the fixed offense.
        analyze_and_send_offenses("app/views/layout/platformos_app.liquid")

        assert_includes(@messenger.sent_messages, empty_diagnostics_notification("app/views/partials/c.liquid"))
      end

      # If you run analyze_and_send_offenses while one is running, the test should be skipped.
      def test_analyze_and_send_offenses_is_throttled
        skip "Flaky test"
        # Setup test in single file mode
        analyze_and_send_offenses("app/views/partials/a.liquid")
        @messenger.sent_messages.clear

        threads = []
        10.times do
          threads << Thread.new do
            analyze_and_send_offenses("app/views/partials/a.liquid")
          end
        end
        threads.each { |t| t.join if t.alive? }

        assert(@messenger.sent_messages.size < threads.size)
      end

      def analyze_and_send_offenses(path, only_single_file: false)
        @engine.analyze_and_send_offenses(
          @storage.path(path),
          PlatformosCheck::Config.from_path(@storage.root),
          only_single_file:
        )
      end

      def diagnostics_notification(path, error_types)
        diagnostics = []
        diagnostics << unused_partial(path) if error_types.include?(:unused)
        diagnostics << syntax_error(path) if error_types.include?(:syntax)
        {
          jsonrpc: "2.0",
          method: "textDocument/publishDiagnostics",
          params: {
            uri: file_uri(@storage.path(path)),
            diagnostics:
          }
        }
      end

      def empty_diagnostics_notification(path)
        diagnostics_notification(path, [])
      end

      def unused_partial(path)
        {
          code: "UnusedPartial",
          message: "This partial is not used",
          range: {
            start: { line: 0, character: 0 },
            end: { line: 0, character: 0 }
          },
          severity: 2,
          source: "platformos-check",
          codeDescription: {
            href: "https://github.com/Platform-OS/platformos-lsp/blob/master/docs/checks/unused_partial.md"
          },
          data: {
            uri: file_uri(@storage.path(path)),
            absolute_path: @storage.path(path).to_s,
            relative_path: path.to_s,
            version: nil
          }
        }
      end

      def syntax_error(path)
        {
          code: "SyntaxError",
          message: "'if' tag was never closed",
          range: {
            start: { line: 0, character: 0 },
            end: { line: 0, character: 16 }
          },
          severity: 1,
          source: "platformos-check",
          codeDescription: {
            href: "https://github.com/Platform-OS/platformos-lsp/blob/master/docs/checks/syntax_error.md"
          },
          data: {
            uri: file_uri(@storage.path(path)),
            absolute_path: @storage.path(path).to_s,
            relative_path: path.to_s,
            version: nil
          }
        }
      end
    end
  end
end
