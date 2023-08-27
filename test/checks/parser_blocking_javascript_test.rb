# frozen_string_literal: true

require "test_helper"

class ParserBlockingJavaScriptTest < Minitest::Test
  def test_async_script_tag
    offenses = analyze_platformos_app(
      PlatformosCheck::ParserBlockingJavaScript.new,
      "app/views/pages/index.liquid" => <<~END
        <html>
        <head>
          <script src="example.com" async></script>
          <script async src="example.com"></script>
          <script async="async" src="example.com"></script>
          <script async="true" src="example.com"></script>
          <script
            async
            src="example.com"
          ></script>
        </head>
        </html>
      END
    )

    assert_offenses("", offenses)
  end

  def test_defer_script_tag
    offenses = analyze_platformos_app(
      PlatformosCheck::ParserBlockingJavaScript.new,
      "app/views/pages/index.liquid" => <<~END
        <html>
        <head>
          <script src="example.com" defer></script>
          <script defer src="example.com"></script>
          <script
            defer
            src="example.com"
          ></script>
        </head>
        </html>
      END
    )

    assert_offenses("", offenses)
  end

  def test_parser_blocking_script_tag
    offenses = analyze_platformos_app(
      PlatformosCheck::ParserBlockingJavaScript.new,
      "app/views/pages/index.liquid" => <<~END
        <html>
        <head>
          <script src="example.com"></script>
        </head>
        </html>
      END
    )

    assert_offenses(<<~END, offenses)
      Missing async or defer attribute on script tag at app/views/pages/index.liquid:3
    END
  end

  def test_parser_blocking_script_over_multiple_lines
    offenses = analyze_platformos_app(
      PlatformosCheck::ParserBlockingJavaScript.new,
      "app/views/pages/index.liquid" => <<~END
        <html>
        <head>
          <script
            src="example.com"
          >
          </script>
        </head>
        </html>
      END
    )

    assert_offenses(<<~END, offenses)
      Missing async or defer attribute on script tag at app/views/pages/index.liquid:3
    END
  end

  def test_parser_blocking_inline_script
    offenses = analyze_platformos_app(
      PlatformosCheck::ParserBlockingJavaScript.new,
      "app/views/pages/index.liquid" => <<~END
        <html>
        <head>
          <script>
            console.log('do some stuff inline');
          </script>
          <script>console.log('do some stuff inline');</script>
          <script type="application/json">
            { "hello": "world" }
          </script>
        </head>
        </html>
      END
    )

    assert_offenses("", offenses)
  end

  def test_repeated_offenses_are_correctly_reported
    offenses = analyze_platformos_app(
      PlatformosCheck::ParserBlockingJavaScript.new,
      "app/views/pages/index.liquid" => <<~END
        <html>
        <head>
          <script src="example.com"></script>
          <script src="example.com"></script>
          <script
            src="example.com/foo"
          ></script>
        </head>
        </html>
      END
    )

    assert_offenses(<<~END, offenses)
      Missing async or defer attribute on script tag at app/views/pages/index.liquid:3
      Missing async or defer attribute on script tag at app/views/pages/index.liquid:4
      Missing async or defer attribute on script tag at app/views/pages/index.liquid:5
    END
  end
end
