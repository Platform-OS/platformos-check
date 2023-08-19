# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class AppBlockValidTagsTest < Minitest::Test
    def test_include_layout_section_tags
      %w[include layout section sections].each do |tag|
        extension_files = {
          "blocks/app.liquid" => <<~BLOCK
            {% #{tag} 'test' %}
            {% schema %}
            { }
            {% endschema %}
          BLOCK
        }
        offenses = analyze_platformos_app(
          AppBlockValidTags.new,
          extension_files
        )

        assert_offenses("App extension blocks cannot contain #{tag} tags at blocks/app.liquid:1", offenses)
      end
    end
  end
end
