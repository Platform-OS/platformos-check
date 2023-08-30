# frozen_string_literal: true

require 'test_helper'

module PlatformosCheck
  module PlatformosLiquid
    class Documentation
      class MarkdownTemplateTest < Minitest::Test
        def setup
          @markdown_template = MarkdownTemplate.new
        end

        def test_render
          entry = SourceIndex::ObjectEntry.new(
            'name' => 'context',
            'summary' => 'A context of the request.',
            'description' => 'A more detailed description of a context.'
          )

          actual_template = @markdown_template.render(entry)
          expected_template = "### [context](https://documentation.platformos.com/developer-guide/variables/context-variable#context)\n" \
                              "A context of the request.\n" \
                              "\n---\n\n" \
                              "A more detailed description of a context."

          assert_equal(expected_template, actual_template)
        end

        def test_render_with_summary_only
          entry = SourceIndex::BaseEntry.new(
            'name' => 'context',
            'summary' => 'A context of the request.'
          )

          actual_template = @markdown_template.render(entry)
          expected_template = "### [context](https://documentation.platformos.com)\n" \
                              "A context of the request." \

          assert_equal(expected_template, actual_template)
        end

        def test_render_with_description_only
          entry = SourceIndex::BaseEntry.new(
            'name' => 'context',
            'description' => 'A more detailed description of a context.'
          )

          actual_template = @markdown_template.render(entry)
          expected_template = "### [context](https://documentation.platformos.com)\n" \
                              "A more detailed description of a context."

          assert_equal(expected_template, actual_template)
        end

        def test_render_with_platformos_documentation_urls
          entry = SourceIndex::BaseEntry.new(
            'name' => 'context',
            'description' => <<~BODY
              When you render [...] [`include` tag](/api/liquid/tags#include) [...],
              [`if`](/api/liquid/tags#if) [`if`](/api/liquid/tags#if)
              [`unless`](/api/liquid/tags#unless) Allows you to specify a [...]
            BODY
          )

          actual_template = @markdown_template.render(entry)
          expected_template = "### [context](https://documentation.platformos.com)\n" \
                              "When you render [...] [`include` tag](https://documentation.platformos.com/api/liquid/tags#include) [...],\n" \
                              "[`if`](https://documentation.platformos.com/api/liquid/tags#if) [`if`](https://documentation.platformos.com/api/liquid/tags#if)\n" \
                              "[`unless`](https://documentation.platformos.com/api/liquid/tags#unless) Allows you to specify a [...]\n"

          assert_equal(expected_template, actual_template)
        end

        def test_object_property_entry_title_link
          entry = SourceIndex::ObjectEntry.new(
            'name' => 'context',
            'properties' => [
              {
                "name" => "location",
                "summary" => "Information about request location"
              }
            ]
          )

          actual_template = @markdown_template.render(entry.properties[0])
          expected_template = "### [location](https://documentation.platformos.com/developer-guide/variables/context-variable#context)\n" \
                              "Information about request location"

          assert_equal(expected_template, actual_template)
        end

        def test_tag_entry_title_link
          entry = SourceIndex::TagEntry.new(
            "name" => "if",
            "summary" => "Renders an expression if a specific condition is `true`."
          )

          actual_template = @markdown_template.render(entry)

          expected_template = "### [if](https://documentation.platformos.com/api-reference/liquid/tags/if)\n" \
                              "Renders an expression if a specific condition is `true`."

          assert_equal(expected_template, actual_template)
        end

        def test_filter_title_link
          entry = SourceIndex::FilterEntry.new(
            "name" => "expand_url_template",
            "summary" => "Expand url template."
          )

          actual_template = @markdown_template.render(entry)

          expected_template = "### [expand_url_template](https://documentation.platformos.com/api-reference/liquid/filters/expand_url_template)\n" \
                              "Expand url template."

          assert_equal(expected_template, actual_template)
        end

        def test_filter_parameter_entry_title_link
          entry = SourceIndex::FilterEntry.new(
            "name" => "stylesheet_tag",
            "summary" => "Generates an HTML `&lt;link&gt;` tag for a given resource URL.",
            "parameters" => [
              "description" => "The type of media that the resource applies to.",
              "name" => "media"
            ]
          )

          actual_template = @markdown_template.render(entry.parameters[0])

          expected_template = "### [media](https://documentation.platformos.com/api-reference/liquid/filters/media)\n" \
                              "The type of media that the resource applies to."

          assert_equal(expected_template, actual_template)
        end
      end
    end
  end
end
