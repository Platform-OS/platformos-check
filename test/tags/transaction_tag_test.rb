# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module Tags
    class TransactionTagTest < Minitest::Test
      def test_transaction_syntax
        offenses = analyze_platformos_app(
          "app/views/pages/index.liquid" => <<~END
            {% liquid
              transaction
                assign var = "hello"
              endtransaction

            %}
          END
        )

        assert_offenses("", offenses)
      end

      def test_transaction_syntax_with_rollback
        offenses = analyze_platformos_app(
          "app/views/pages/index.liquid" => <<~END
            {% liquid
              transaction
                assign var = "hello"
                if var
                  rollback
                endif
              endtransaction

            %}
          END
        )

        assert_offenses("", offenses)
      end
    end
  end
end
