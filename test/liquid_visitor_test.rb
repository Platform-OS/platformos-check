# frozen_string_literal: true

require "test_helper"

class LiquidVisitorTest < Minitest::Test
  def setup
    @tracer = TracerCheck.new
    @visitor = PlatformosCheck::LiquidVisitor.new(PlatformosCheck::Checks.new([@tracer]), PlatformosCheck::DisabledChecks.new)
  end

  def test_assign
    app_file = parse_liquid(<<~END)
      {% assign x = 'hello' %}
    END
    @visitor.visit_liquid_file(app_file)

    assert_equal([
                   :on_document,
                   :on_tag,
                   :on_assign,
                   :on_variable,
                   :on_string, "hello",
                   :after_variable,
                   :after_assign,
                   :after_tag,
                   :on_string, "\n",
                   :after_document
                 ], @tracer.calls)
  end

  def test_if
    app_file = parse_liquid(<<~END)
      {% if x == 'condition' %}
        {% assign x = 'hello' %}
      {% else %}
      {% endif %}
    END
    @visitor.visit_liquid_file(app_file)

    assert_equal([
                   :on_document,
                   :on_tag,
                   :on_if,
                   :on_condition,
                   :on_variable_lookup,
                   :after_variable_lookup,
                   :on_string, "condition",
                   :on_block_body,
                   :on_tag,
                   :on_assign,
                   :on_variable,
                   :on_string, "hello",
                   :after_variable,
                   :after_assign,
                   :after_tag,
                   :after_block_body,
                   :after_condition,
                   :on_else_condition,
                   :on_block_body,
                   :after_block_body,
                   :after_else_condition,
                   :after_if,
                   :after_tag,
                   :on_string, "\n",
                   :after_document
                 ], @tracer.calls)
  end

  def test_try_rc
    app_file = parse_liquid(<<~END)
      {% liquid
        try_rc
          function res = 'lib/commands/complex_func', object: 'Hello'
        catch err
          log err, type: 'complex_func error'
        ensure
          assign res = -1
        endtry_rc
      %}
    END
    @visitor.visit_liquid_file(app_file)

    assert_equal([:on_document,
                  :on_tag,
                  :on_try,
                  :on_block_body,
                  :on_tag,
                  :on_function,
                  :on_string, "lib/commands/complex_func",
                  :on_string, "res",
                  :on_string, "Hello",
                  :after_function,
                  :after_tag,
                  :after_block_body,
                  :on_block_body,
                  :on_tag,
                  :on_log,
                  :on_variable_lookup,
                  :after_variable_lookup,
                  :on_string, "complex_func error",
                  :after_log,
                  :after_tag,
                  :after_block_body,
                  :on_block_body,
                  :on_tag,
                  :on_assign,
                  :on_variable,
                  :on_integer, -1,
                  :after_variable,
                  :after_assign,
                  :after_tag,
                  :after_block_body,
                  :after_try,
                  :after_tag,
                  :on_string, "\n",
                  :after_document], @tracer.calls)
  end

  def test_render
    app_file = parse_liquid(<<~END)
      {% for block in section.blocks %}
        {% assign x = 1 %}
        {% render block with x %}
      {% endfor %}
    END
    @visitor.visit_liquid_file(app_file)

    assert_equal([
                   :on_document,
                   :on_tag,
                   :on_for,
                   :on_block_body,
                   :on_string,
                   "\n" + "  ",
                   :on_tag,
                   :on_assign,
                   :on_variable,
                   :on_integer,
                   1,
                   :after_variable,
                   :after_assign,
                   :after_tag,
                   :on_string,
                   "\n" + "  ",
                   :on_tag,
                   :on_render,
                   :on_variable_lookup,
                   :after_variable_lookup,
                   :on_variable_lookup,
                   :after_variable_lookup,
                   :after_render,
                   :after_tag,
                   :on_string,
                   "\n",
                   :after_block_body,
                   :on_variable_lookup,
                   :on_string,
                   "blocks",
                   :after_variable_lookup,
                   :after_for,
                   :after_tag,
                   :on_string,
                   "\n",
                   :after_document
                 ], @tracer.calls)
  end

  def test_form
    app_file = parse_liquid(<<~END)
      {% form 'type', object, key: value %}
      {% endform %}
    END
    @visitor.visit_liquid_file(app_file)

    assert_equal([
                   :on_document,
                   :on_tag,
                   :on_form,
                   :on_string, "\n",
                   :after_form,
                   :after_tag,
                   :on_string, "\n",
                   :after_document
                 ], @tracer.calls)
  end

  def test_parse_json
    app_file = parse_liquid(<<~END)
      {% parse_json x %}
        { "hello": var }
      {% endparse_json %}
    END
    @visitor.visit_liquid_file(app_file)

    assert_equal(
      [:on_document,
       :on_tag,
       :on_parse_json,
       :on_string, "\n  { \"hello\": var }\n",
       :on_string, "x",
       :after_parse_json,
       :after_tag,
       :on_string, "\n",
       :after_document], @tracer.calls
    )
  end
end
