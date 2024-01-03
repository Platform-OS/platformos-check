# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class FormAuthenticityTokenTest < Minitest::Test
    def test_no_offense_with_authenticity_token
      offenses = analyze_platformos_app(
        FormAuthenticityToken.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create" method="post">
            <input type="text" name="title">
            <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">
            <button type="submit">Save</button>
          </form>
        END
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_for_get
      offenses = analyze_platformos_app(
        FormAuthenticityToken.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create" method="GET">
            <input type="text" name="title">
            <button type="submit">Save</button>
          </form>
        END
      )

      assert_offenses("", offenses)
    end

    def test_offense_for_variable
      offenses = analyze_platformos_app(
        FormAuthenticityToken.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create" method="{{ var }}">
            <input type="text" name="title">
            <button type="submit">Save</button>
          </form>
        END
      )

      assert_offenses(<<~END, offenses)
        Missing authenticity_token input <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}"> at app/views/pages/index.liquid:1
      END
    end

    def test_no_offense_if_method_missing
      offenses = analyze_platformos_app(
        FormAuthenticityToken.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create">
            <input type="text" name="title">
            <button type="submit">Save</button>
          </form>
        END
      )

      assert_offenses("", offenses)
    end

    def test_reports_missing_authenticity_token_input
      offenses = analyze_platformos_app(
        FormAuthenticityToken.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create" method="post">
            <input type="text" name="title">
            <button type="submit">Save</button>
          </form>
        END
      )

      assert_offenses(<<~END, offenses)
        Missing authenticity_token input <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}"> at app/views/pages/index.liquid:1
      END
    end

    def test_reports_missing_authenticity_token_name
      offenses = analyze_platformos_app(
        FormAuthenticityToken.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create" method="post">
            <input type="hidden" value="{{ context.authenticity_token }}">
            <input type="text" name="title">
            <button type="submit">Save</button>
          </form>
        END
      )

      assert_offenses(<<~END, offenses)
        Missing authenticity_token input <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}"> at app/views/pages/index.liquid:1
      END
    end

    def test_reports_missing_authenticity_token_value
      offenses = analyze_platformos_app(
        FormAuthenticityToken.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create" method="post">
            <input type="hidden" name="authenticity_token">
            <input type="text" name="title">
            <button type="submit">Save</button>
          </form>
        END
      )

      assert_offenses(<<~END, offenses)
        Missing authenticity_token input <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}"> at app/views/pages/index.liquid:1
      END
    end

    def test_duplicated_authenticity_token_inputs
      offenses = analyze_platformos_app(
        FormAuthenticityToken.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create" method="post">
            <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">
            <input type="text" name="title">
            <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">
            <button type="submit">Save</button>
          </form>
        END
      )

      assert_offenses(<<~END, offenses)
        Duplicated authenticity_token inputs at app/views/pages/index.liquid:1
      END
    end

    def test_corrects_missing_authenticity_token
      expected_sources = {
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create" method="post">
          <input type="hidden" name="authenticity_token" value="{{ context.authenticity_token }}">
            <input type="text" name="title">
            <button type="submit">Save</button>
          </form>
        END
      }
      sources = fix_platformos_app(
        FormAuthenticityToken.new,
        "app/views/pages/index.liquid" => <<~END
          <form action="/dummy/create" method="post">
            <input type="text" name="title">
            <button type="submit">Save</button>
          </form>
        END
      )

      sources.each do |path, source|
        assert_equal(expected_sources[path], source)
      end
    end
  end
end
