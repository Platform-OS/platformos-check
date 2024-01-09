# frozen_string_literal: true

require "test_helper"

class ConvertIncludeToRenderTest < Minitest::Test
  def test_reports_on_include_if_missing
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

  def test_does_not_reports_when_include_is_variable
    offenses = analyze_platformos_app(
      PlatformosCheck::ConvertIncludeToRender.new,
      "app/views/pages/index.liquid" => <<~END,
        {% assign templ_name = 'foo' %}
        {% include foo %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_reports_on_include_when_does_not_contain_break
    offenses = analyze_platformos_app(
      PlatformosCheck::ConvertIncludeToRender.new,
      "app/views/pages/index.liquid" => <<~END,
        {% include 'foo' %}
      END
      "app/views/partials/foo.liquid" => <<~END
        {% liquid
          if a
            print "a"
          endif
        %}
      END
    )

    assert_offenses(<<~END, offenses)
      `include` is deprecated - convert it to `render` at app/views/pages/index.liquid:1
    END
  end

  def test_does_not_reports_when_include_contains_break
    offenses = analyze_platformos_app(
      PlatformosCheck::ConvertIncludeToRender.new,
      "app/views/pages/index.liquid" => <<~END,
        {% include 'foo' %}
      END
      "app/views/partials/foo.liquid" => <<~END
        {% liquid
          if a
            break
          endif
        %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_does_not_reports_in_original_when_nested_include
    offenses = analyze_platformos_app(
      PlatformosCheck::ConvertIncludeToRender.new,
      "app/views/pages/index.liquid" => <<~END,
        {% include 'foo' %}
      END
      "app/views/partials/foo.liquid" => <<~END,
        {% liquid
          include 'bar'
        %}
      END
      "app/views/partials/bar.liquid" => <<~END
        {% liquid
          if a
            print "a"
          endif
        %}
      END
    )

    # note there is no offense for app/views/pages/index.liquid, only for foo.liquid

    assert_offenses(<<~END, offenses)
      `include` is deprecated - convert it to `render` at app/views/partials/foo.liquid:2
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
