# frozen_string_literal: true

require "test_helper"

class RequiredLayoutObjectTest < Minitest::Test
  def test_do_not_report_when_required_objects_are_present
    offenses = analyze_layout_platformos_app(
      <<~END
        {{content_for_header}}
        {{content_for_layout}}
      END
    )

    assert_offenses("", offenses)
  end

  def test_picks_up_variable_lookups_only
    offenses = analyze_layout_platformos_app(
      <<~END
        {{"a"}}
        {{"1"}}
        {{ false }}
        {{content_for_header}}
        {{content_for_layout}}
      END
    )

    assert_offenses("", offenses)
  end

  def test_report_offense_on_missing_content_for_header
    offenses = analyze_layout_platformos_app("{{content_for_layout}}")

    assert_offenses(
      "layout/platformos_app must include {{content_for_header}} at layout/platformos_app.liquid",
      offenses
    )
  end

  def test_report_offense_on_missing_content_for_layout
    offenses = analyze_layout_platformos_app("{{content_for_header}}")

    assert_offenses(
      "layout/platformos_app must include {{content_for_layout}} at layout/platformos_app.liquid",
      offenses
    )
  end

  def test_creates_missing_content_for_layout
    expected_sources = {
      "layout/platformos_app.liquid" => <<~END
        <!DOCTYPE html>
        <html>
          <head>
            {{ content_for_header }}
          </head>
          <body>
            {{ content_for_layout }}
          </body>
        </html>
      END
    }
    sources = fix_platformos_app(
      PlatformosCheck::RequiredLayoutObject.new,
      "layout/platformos_app.liquid" => <<~END
        <!DOCTYPE html>
        <html>
          <head>
            {{ content_for_header }}
          </head>
          <body>
          </body>
        </html>
      END
    )

    sources.each do |path, source|
      assert_equal(expected_sources[path], source)
    end
  end

  def test_creates_missing_content_for_header
    expected_sources = {
      "layout/platformos_app.liquid" => <<~END
        <!DOCTYPE html>
        <html>
          <head>
            {{ content_for_header }}
          </head>
          <body>
            {{ content_for_layout }}
          </body>
        </html>
      END
    }
    sources = fix_platformos_app(
      PlatformosCheck::RequiredLayoutObject.new,
      "layout/platformos_app.liquid" => <<~END
        <!DOCTYPE html>
        <html>
          <head>
          </head>
          <body>
            {{ content_for_layout }}
          </body>
        </html>
      END
    )

    sources.each do |path, source|
      assert_equal(expected_sources[path], source)
    end
  end

  def test_no_head_or_body_tag
    expected_sources = {
      "layout/platformos_app.liquid" => <<~END
        <!DOCTYPE html>
        <html>
        </html>
      END
    }
    sources = fix_platformos_app(
      PlatformosCheck::RequiredLayoutObject.new,
      "layout/platformos_app.liquid" => <<~END
        <!DOCTYPE html>
        <html>
        </html>
      END
    )

    sources.each do |path, source|
      assert_equal(expected_sources[path], source)
    end
  end

  private

  def analyze_layout_platformos_app(content)
    analyze_platformos_app(
      PlatformosCheck::RequiredLayoutObject.new,
      "layout/platformos_app.liquid" => content
    )
  end
end
