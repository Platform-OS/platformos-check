# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class GraphqlInForLoopTest < Minitest::Test
    def test_no_offense_with_proper_path
      offenses = analyze_platformos_app(
        GraphqlInForLoop.new,
        "app/views/pages/index.liquid" => <<~END
          {% assign arr = 'a,b,c' | split: ','}
          {% graphql _ = 'my/graphql' %}
          {% for el in arr %}
            {% print el %}
          {% endfor %}
          {% graphql _ = 'my/graphql' %}
        END
      )

      assert_offenses("", offenses)
    end

    def test_reports_graphql_in_for_loop
      offenses = analyze_platformos_app(
        GraphqlInForLoop.new,
        "app/views/pages/index.liquid" => <<~END
          {% assign arr = 'a,b,c' | split: ','}
          {% graphql _ = 'my/graphql' %}
          {% for el in arr %}
            {% graphql _ = 'my/graphql' %}
            {% print el %}
            {% graphql _ = 'my/another_graphql' %}
          {% endfor %}
        END
      )

      assert_offenses(<<~END, offenses)
        Do not invoke GraphQL in a for loop (my/graphql) at app/views/pages/index.liquid:4
        Do not invoke GraphQL in a for loop (my/another_graphql) at app/views/pages/index.liquid:6
      END
    end

    def test_no_offense_if_for_in_background
      offenses = analyze_platformos_app(
        GraphqlInForLoop.new,
        "app/views/pages/index.liquid" => <<~END
          {% assign arr = 'a,b,c' | split: ','}
          {% background source_name: "my job" %}
            {% for el in arr %}
              {% graphql _ = 'my/graphql' %}
              {% print el %}
              {% graphql _ = 'my/graphql' %}
            {% endfor %}
          {% endbackground %}
        END
      )

      assert_offenses('', offenses)
    end

    def test_no_offense_if_background_in_for
      offenses = analyze_platformos_app(
        GraphqlInForLoop.new,
        "app/views/pages/index.liquid" => <<~END
          {% assign arr = 'a,b,c' | split: ','}
            {% for el in arr %}
              {% background source_name: "my job" %}
                {% graphql _ = 'my/graphql' %}
                {% print el %}
                {% graphql _ = 'my/graphql' %}
              {% endbackground %}
            {% endfor %}
        END
      )

      assert_offenses('', offenses)
    end

    def test_no_offense_if_render_not_in_for
      offenses = analyze_platformos_app(
        GraphqlInForLoop.new,
        "app/views/pages/index.liquid" => <<~END,
          {% for el in arr %}
            {% print el %}
          {% endfor %}
          {% render "my/render", el: el %}
        END
        "app/views/partials/my/render.liquid" => <<~END,
          {% include "my/include", el: el %}
        END
        "app/views/partials/my/include.liquid" => <<~END
          {% graphql "my/graphql" %}
        END
      )

      assert_offenses('', offenses)
    end

    def test_reports_when_graphql_is_in_nested_includes_and_renders
      offenses = analyze_platformos_app(
        GraphqlInForLoop.new,
        "app/views/pages/index.liquid" => <<~END,
          {% for el in arr %}
            {% render "my/render", el: el %}
          {% endfor %}
        END
        "app/views/partials/my/render.liquid" => <<~END,
          {% include "my/include", el: el %}
        END
        "app/views/partials/my/include.liquid" => <<~END
          {% graphql _ = "my/nested/graphql" %}
        END
      )

      assert_offenses(<<~END, offenses)
        Do not invoke GraphQL in a for loop (my/nested/graphql) at app/views/pages/index.liquid:2
      END
    end

    def test_reports_graphql_variable_name
      offenses = analyze_platformos_app(
        GraphqlInForLoop.new,
        "app/views/pages/index.liquid" => <<~END,
          {% for el in arr %}
            {% render "my/render", el: el %}
          {% endfor %}
        END
        "app/views/partials/my/render.liquid" => <<~END,
          {% include "my/include", el: el %}
        END
        "app/views/partials/my/include.liquid" => <<~END
          {% graphql _ = el %}
        END
      )

      assert_offenses(<<~END, offenses)
        Do not invoke GraphQL in a for loop (variable: el) at app/views/pages/index.liquid:2
      END
    end

    def test_no_offense_if_render_does_not_exist
      offenses = analyze_platformos_app(
        GraphqlInForLoop.new,
        "app/views/pages/index.liquid" => <<~END
          {% for el in arr %}
            {% render "my/render", el: el %}
          {% endfor %}
        END
      )

      assert_offenses('', offenses)
    end
  end
end
