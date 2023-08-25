# frozen_string_literal: true

require "test_helper"

class UnusedAssignTest < Minitest::Test
  def test_reports_unused_assigns
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% assign x = 1 %}
      END
    )

    assert_offenses(<<~END, offenses)
      `x` is never used at app/views/partials/index.liquid:1
    END
  end

  def test_reports_unused_function_assigns
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% function x = 'my_partial' %}
      END
    )

    assert_offenses(<<~END, offenses)
      `x` is never used at app/views/partials/index.liquid:1
    END
  end

  def test_reports_unused_parse_json
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% parse_json x %}
          { "hello": "world" }
        {% endparse_json %}
      END
    )

    assert_offenses(<<~END, offenses)
      `x` is never used at app/views/partials/index.liquid:1
    END
  end

  def test_reports_unused_graphql_query_assigns
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% graphql x = 'my_query', arg: 'hello', arg2: 'world' | dig: 'resulsts' | map: 'id' %}
      END
    )

    assert_offenses(<<~END, offenses)
      `x` is never used at app/views/partials/index.liquid:1
    END
  end

  def test_reports_unused_graphql_inline_assigns
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% graphql x %}
          query records {
            records(per_page: 20, table: "my_table") {
              results {
                id
              }
            }
          }
        {% endgraphql %}
      END
    )

    assert_offenses(<<~END, offenses)
      `x` is never used at app/views/partials/index.liquid:1
    END
  end

  def test_do_not_reports_unused_function_assigns_if_starts_with_underscore
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% function _x = 'my_partial' %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_do_not_reports_unused_function_assigns_if_useed_in_another_function_call
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% assign var = "hello" %}
        {% function _x = 'my_partial', hello: var %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_do_not_report_used_assigns
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% assign a = 1 %}
        {{ a }}
        {% assign b = 1 %}
        {{ 'a' | t: b }}
        {% assign c = 1 %}
        {{ 'a' | t: tags: c }}
        {% liquid
         assign d = 1
         render 'foo' with d
         assign e = "01234" | split: ""
         render 'foo' for e as item
         assign g = "hello"
         print g
         assign h = "my log"
         log h, type: 'warning'
         assign i = "key"
         assign j = "val"
         assign hash = '{}' | parse_json
         hash_assign hash[i] = "val"
         hash_assign hash['key'] = j
         assign cache_key = 'my-key'
         assign expire_time = 10
         cache cache_key, expire: expire_time
         endcache
         assign graph_arg = 10
         graphql res = 'my_query', arg: graph_arg
         echo res
         echo hash
         assign url = '/my-page'
         assign session_var = 'val'
         session key = session_var
         assign global_var = 'global'
         export global_var, namespace: 'globals'
         redirect_to url
         assign u_id = 25
         sign_in user_id: u_id
         assign strategy = 'hcaptcha'
         spam_protection strategy
         assign f = "val"
         return f
        %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_error; end

  def test_do_not_report_used_assigns_bracket_syntax
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% liquid
          assign resource = request.page_type
          assign meta_value = [resource].metafields.namespace.key
          echo meta_value
        %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_do_not_report_assigns_used_before_defined
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% unless a %}
          {% assign a = 1 %}
        {% endunless %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_do_not_report_assigns_used_in_includes
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END,
        {% assign a = 1 %}
        {% include 'using' %}
      END
      "snippets/using.liquid" => <<~END
        {{ a }}
      END
    )

    assert_offenses("", offenses)
  end

  def test_recursion_in_includes
    offenses = analyze_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END,
        {% assign a = 1 %}
        {% include 'one' %}
      END
      "snippets/one.liquid" => <<~END,
        {% include 'two' %}
        {{ a }}
      END
      "snippets/two.liquid" => <<~END
        {% if some_end_condition %}
          {% include 'one' %}
        {% endif %}
      END
    )

    assert_offenses("", offenses)
  end

  def test_removes_unused_assign
    expected_sources = {
      "app/views/partials/index.liquid" => "\n"
    }
    sources = fix_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% assign x = 1 %}
      END
    )

    sources.each do |path, source|
      assert_equal(expected_sources[path], source)
    end
  end

  def test_removes_unused_assign_liquid_block
    expected_sources = {
      "app/views/partials/index.liquid" => <<~END
        {% liquid
          assign x = 1
          assign y = 2
        %}
        {{ x }}
        {{ y }}
      END
    }
    sources = fix_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        {% liquid
          assign x = 1
          assign y = 2
          assign z = 3
        %}
        {{ x }}
        {{ y }}
      END
    )

    sources.each do |path, source|
      assert_equal(expected_sources[path], source)
    end
  end

  def test_removes_unused_assign_middle_of_line
    expected_sources = {
      "app/views/partials/index.liquid" => <<~END
        <p>test case</p><p>test case</p>
      END
    }
    sources = fix_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        <p>test case</p>{% assign x = 1 %}<p>test case</p>
      END
    )

    sources.each do |path, source|
      assert_equal(expected_sources[path], source)
    end
  end

  def test_removes_unused_assign_leaves_html
    expected_sources = {
      "app/views/partials/index.liquid" => <<~END
        <p>test case</p>
      END
    }
    sources = fix_platformos_app(
      PlatformosCheck::UnusedAssign.new,
      "app/views/partials/index.liquid" => <<~END
        <p>test case</p>{% assign x = 1 %}
      END
    )

    sources.each do |path, source|
      assert_equal(expected_sources[path], source)
    end
  end
end
