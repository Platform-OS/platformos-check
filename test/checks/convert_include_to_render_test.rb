# frozen_string_literal: true

require "test_helper"

class ConvertIncludeToRenderTest < Minitest::Test
  def test_reports_on_include
    offenses = analyze_platformos_app(
      PlatformosCheck::ConvertIncludeToRender.new,
      "app/views/pages/index.liquid" => <<~END
        {% include 'foo' %}
      END
    )

    assert_offenses(<<~END, offenses)
      `include` is deprecated - convert it to `render` at app/views/pages/index.liquid:1
    END
  end

  def test_does_not_reports_on_render
    offenses = analyze_platformos_app(
      PlatformosCheck::ConvertIncludeToRender.new,
      "app/views/pages/index.liquid" => <<~END
        {% render 'foo' %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_corrects_include
    skip "To be fixed"
    sources = fix_platformos_app(
      PlatformosCheck::ConvertIncludeToRender.new,
      "app/views/pages/index.liquid" => <<~END,
        {% include 'foo' %}
        {% assign greeting = "hello world" %}
        {% include 'greeting' %}
      END
      "app/views/partials/greeting.liquid" => <<~END
        {{ greeting }}
      END
    )
    expected_sources = {
      "app/views/pages/index.liquid" => <<~END,
        {% render 'foo' %}
        {% assign greeting = "hello world" %}
        {% render 'greeting', greeting: greeting %}
      END
      "app/views/partials/greeting" => <<~END
        {{ greeting }}
      END
    }

    sources.each do |path, source|
      assert_equal(expected_sources[path], source)
    end
  end
end
