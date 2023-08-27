# frozen_string_literal: true

require "test_helper"

class UnusedPartialTest < Minitest::Test
  def test_finds_unused
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedPartial.new,
      "app/views/pages/index.liquid" => <<~END,
        {% include 'muffin' %}
      END
      "app/views/partials/muffin.liquid" => <<~END,
        Here's a muffin
      END
      "app/views/partials/unused.liquid" => <<~END
        This is not used
      END
    )

    assert_offenses(<<~END, offenses)
      This partial is not used at app/views/partials/unused.liquid
    END
  end

  def test_ignores_dynamic_includes
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedPartial.new,
      "app/views/pages/index.liquid" => <<~END,
        {% assign name = 'muffin' %}
        {% include name %}
      END
      "app/views/partials/muffin.liquid" => <<~END,
        Here's a muffin
      END
      "app/views/partials/unused.liquid" => <<~END
        This is not used
      END
    )

    assert_offenses("", offenses)
  end

  def test_does_not_turn_off_the_check_because_of_potential_render_block
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedPartial.new,
      "app/views/pages/index.liquid" => <<~END,
        {% for name in section.blocks %}
          {% render name %}
        {% endfor %}
      END
      "app/views/partials/unused.liquid" => <<~END
        This is not used
      END
    )

    assert_offenses(<<~END, offenses)
      This partial is not used at app/views/partials/unused.liquid
    END
  end

  def test_does_turn_off_the_check_because_of_dynamic_include_in_for_loop
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedPartial.new,
      "app/views/pages/index.liquid" => <<~END,
        {% for name in includes %}
          {% include name %}
        {% endfor %}
      END
      "app/views/partials/unused.liquid" => <<~END
        This is not used
      END
    )

    assert_offenses("", offenses)
  end

  def test_removes_unused_partial
    platformos_app = make_platformos_app(
      "app/views/pages/index.liquid" => <<~END,
        {% include 'muffin' %}
      END
      "app/views/partials/muffin.liquid" => <<~END,
        Here's a muffin
      END
      "app/views/partials/unused.liquid" => <<~END
        This is not used
      END
    )

    analyzer = PlatformosCheck::Analyzer.new(platformos_app, [PlatformosCheck::UnusedPartial.new], true)
    analyzer.analyze_platformos_app
    analyzer.correct_offenses

    refute_includes(platformos_app.storage.files, "app/views/partials/unused.liquid")
  end
end
