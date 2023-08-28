# frozen_string_literal: true

require "test_helper"

class RequiredLayoutObjectTest < Minitest::Test
  def test_do_not_report_when_required_objects_are_present
    offenses = analyze_layout_platformos_app(
      <<~END
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
        {{content_for_layout}}
      END
    )

    assert_offenses("", offenses)
  end

  def test_report_offense_on_missing_content_for_layout_for_module
    offenses = analyze_platformos_app(
      PlatformosCheck::RequiredLayoutObject.new,
      "modules/my-module/public/views/layouts/admin.liquid" => <<~END
        <!DOCTYPE html>
        <html>
        </html>
      END
    )

    assert_offenses(
      "layout must include {{content_for_layout}} at modules/my-module/public/views/layouts/admin.liquid",
      offenses
    )
  end

  def test_report_offense_on_missing_content_for_layout
    offenses = analyze_layout_platformos_app("")

    assert_offenses(
      "layout must include {{content_for_layout}} at app/views/layouts/application.liquid",
      offenses
    )
  end

  def test_creates_missing_content_for_layout
    expected_sources = {
      "app/views/layouts/application.liquid" => <<~END
        <!DOCTYPE html>
        <html>
          <body>
            {{ content_for_layout }}
          </body>
        </html>
      END
    }
    sources = fix_platformos_app(
      PlatformosCheck::RequiredLayoutObject.new,
      "app/views/layouts/application.liquid" => <<~END
        <!DOCTYPE html>
        <html>
          <body>
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
      "app/views/layouts/application.liquid" => <<~END
        <!DOCTYPE html>
        <html>
        </html>
      END
    }
    sources = fix_platformos_app(
      PlatformosCheck::RequiredLayoutObject.new,
      "app/views/layouts/application.liquid" => <<~END
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
      "app/views/layouts/application.liquid" => content
    )
  end
end
