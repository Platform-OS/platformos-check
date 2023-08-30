# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class CorrectorTest < Minitest::Test
    def setup
      @contents = <<~END
        <p>
          {{1 + 2}}
          {%
            include
            "foo"
          %}
        </p>
      END
      @platformos_app = make_platformos_app("app/views/pages/index.liquid" => @contents)
      @app_file = @platformos_app["app/views/pages/index"]
    end

    def test_insert_after_adds_suffix
      node = stub(
        app_file: @app_file,
        start_index: @contents.index('1'),
        end_index: @contents.index('2') + 1
      )
      corrector = Corrector.new(app_file: @app_file)
      corrector.insert_after(node, " ")
      @app_file.write

      assert_equal("{{1 + 2 }}", @app_file.source_excerpt(2))
    end

    def test_insert_after_character_range_adds_suffix_to_character_range
      node = stub(
        app_file: @app_file,
        start_index: @contents.index('1'),
        end_index: @contents.index('2') + 1
      )
      corrector = Corrector.new(app_file: @app_file)
      corrector.insert_after(
        node,
        "hi muffin",
        @contents.index("{{1 + 2}}")...@contents.index("{{1 + 2}}") + "{{1 + 2}}".size
      )
      @app_file.write

      assert_equal("{{1 + 2}}hi muffin", @app_file.source_excerpt(2))
    end

    def test_insert_before_adds_prefix
      node = stub(
        app_file: @app_file,
        start_index: @contents.index('1'),
        end_index: @contents.index('2') + 1
      )
      corrector = Corrector.new(app_file: @app_file)
      corrector.insert_before(node, " ")
      @app_file.write

      assert_equal("{{ 1 + 2}}", @app_file.source_excerpt(2))
    end

    def test_insert_before_character_range_adds_prefix_to_character_range
      node = stub(
        app_file: @app_file,
        start_index: @contents.index('1'),
        end_index: @contents.index('2') + 1
      )
      corrector = Corrector.new(app_file: @app_file)
      corrector.insert_before(
        node,
        "hi muffin",
        @contents.index("{{1 + 2}}")...@contents.index("{{1 + 2}}") + "{{1 + 2}}".size
      )
      @app_file.write

      assert_equal("hi muffin{{1 + 2}}", @app_file.source_excerpt(2))
    end

    def test_replace_replaces_markup
      node = stub(
        app_file: @app_file,
        start_index: @contents.index('1'),
        end_index: @contents.index('2') + 1,
        :markup= => ()
      )
      corrector = Corrector.new(app_file: @app_file)
      corrector.replace(node, "3 + 4")
      @app_file.write

      assert_equal("{{3 + 4}}", @app_file.source_excerpt(2))
    end

    def test_replace_character_range_replaces_character_range
      node = stub(
        app_file: @app_file,
        start_index: @contents.index('1'),
        end_index: @contents.index('2') + 1,
        :markup= => ()
      )
      corrector = Corrector.new(app_file: @app_file)
      corrector.replace(
        node,
        "hi muffin",
        @contents.index("{1 + 2}")...@contents.index("{1 + 2}") + "{1 + 2}".size
      )
      @app_file.write

      assert_equal("{hi muffin}", @app_file.source_excerpt(2))
    end

    def test_wrap_adds_prefix_and_suffix
      node = stub(
        app_file: @app_file,
        start_index: @contents.index('1'),
        end_index: @contents.index('2') + 1,
        :markup= => ()
      )
      corrector = Corrector.new(app_file: @app_file)
      corrector.wrap(node, "a", "b")
      @app_file.write

      assert_equal("{{a1 + 2b}}", @app_file.source_excerpt(2))
    end

    def test_handles_multiple_updates_properly
      node = stub(
        app_file: @app_file,
        start_index: @contents.index('1'),
        end_index: @contents.index('2') + 1
      )
      corrector = Corrector.new(app_file: @app_file)
      corrector.wrap(node, "a", "b")
      corrector.insert_before(node, " ")
      corrector.insert_after(node, " ")
      @app_file.write

      assert_equal("{{ a1 + 2b }}", @app_file.source_excerpt(2))
    end

    def test_handles_multiline_updates
      node = stub(
        app_file: @app_file,
        start_index: @contents.index('{%') + 2,
        end_index: @contents.index('%}'),
        :markup= => ()
      )
      corrector = Corrector.new(app_file: @app_file)
      corrector.replace(node, "\n    render\n    'foo',\n    product: product\n  ")
      @app_file.write

      assert_equal(<<~UPDATED_SOURCE, @app_file.source)
        <p>
          {{1 + 2}}
          {%
            render
            'foo',
            product: product
          %}
        </p>
      UPDATED_SOURCE
    end

    def test_replaces_schema_body
      contents = <<~END
        {% schema %}
          {
            "name": {
              "en": "Hello",
              "fr": "Bonjour"
            },
            "settings": [
              {
                "id": "product",
                "label": {
                  "en": "Product"
                }
              }
            ]
          }
        {% endschema %}
      END
      platformos_app = make_platformos_app("app/views/pages/index.liquid" => contents)
      app_file = platformos_app["app/views/pages/index"]
      node = stub(
        app_file:,
        inner_markup_start_index: 12,
        inner_markup_end_index: 205,
        :markup= => ()
      )
      corrector = Corrector.new(app_file:)
      schema =  { "name" => { "en" => "Hello", "fr" => "Bonjour" }, "settings" => [{ "id" => "product", "label" => { "en" => "Product", "fr" => "TODO" } }] }
      corrector.replace_inner_markup(node, "\n  #{JSON.pretty_generate(schema, array_nl: "\n  ", object_nl: "\n  ")}\n")
      app_file.write

      assert_equal(<<~UPDATED_SOURCE, app_file.source)
        {% schema %}
          {
            "name": {
              "en": "Hello",
              "fr": "Bonjour"
            },
            "settings": [
              {
                "id": "product",
                "label": {
                  "en": "Product",
                  "fr": "TODO"
                }
              }
            ]
          }
        {% endschema %}
      UPDATED_SOURCE
    end
  end
end
