# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class FormActionTest < Minitest::Test
    def test_no_offense_with_proper_path
      offenses = analyze_platformos_app(
        FormAction.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create">
          </form>
        END
      )

      assert_offenses("", offenses)
    end

    def test_reports_invalid_action
      offenses = analyze_platformos_app(
        FormAction.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="dummy/create">
          </form>
        END
      )

      assert_offenses(<<~END, offenses)
        Use action="/dummy/create" (start with /) to ensure the form can be submitted multiple times in case of validation errors at app/views/pages/index.liquid:1
      END
    end

    def test_reports_invalid_action_without_quotes
      offenses = analyze_platformos_app(
        FormAction.new,
        "app/views/pages/index.liquid" => <<~END
          <form action=dummy/create>
          </form>
        END
      )

      assert_offenses(<<~END, offenses)
        Use action="/dummy/create" (start with /) to ensure the form can be submitted multiple times in case of validation errors at app/views/pages/index.liquid:1
      END
    end

    def test_no_offense_when_action_dynamic
      offenses = analyze_platformos_app(
        FormAction.new,
        "app/views/pages/index.liquid" => <<~END
          {% assign var = "/dummy/create" %}
          <form action="{{ var }}">
          </form>
        END
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_when_action_dynamic_via_render
      offenses = analyze_platformos_app(
        FormAction.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="{% render 'link_to' %}">
          </form>
        END
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_when_external_url
      offenses = analyze_platformos_app(
        FormAction.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="https://example.com">
          </form>
        END
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_when_no_action
      offenses = analyze_platformos_app(
        FormAction.new,
        "app/views/pages/index.liquid" => <<~END
          <form>
          </form>
        END
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_when_action_blank
      offenses = analyze_platformos_app(
        FormAction.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="">
          </form>
        END
      )

      assert_offenses("", offenses)
    end
  end
end
