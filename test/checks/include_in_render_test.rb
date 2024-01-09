# frozen_string_literal: true

require "test_helper"

class IncludeInRenderTest < Minitest::Test
  def test_does_not_reports_when_render_used_in_nested_file
    offenses = analyze_platformos_app(
      PlatformosCheck::IncludeInRender.new,
      "app/views/pages/index.liquid" => <<~END,
        {% render 'foo' %}
      END
      "app/views/partials/foo.liquid" => <<~END,
        {% liquid
          render 'bar'
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

    assert_offenses("", offenses)
  end

  def test_reports_when_include_used_inside_render
    offenses = analyze_platformos_app(
      PlatformosCheck::IncludeInRender.new,
      "app/views/pages/index.liquid" => <<~END,
        {% render 'foo' %}
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

    assert_offenses(<<~END, offenses)
      `render` context does not allow to use `include`, either remove all includes from `app/views/partials/foo.liquid` or change `render` to `include` at app/views/pages/index.liquid:1
    END
  end
end
