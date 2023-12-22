# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class UnreachableCodeTest < Minitest::Test
    def test_no_offense_with_proper_flow
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            if x

              break

            else

              assign x = "hello"

            endif
          %}

        END
      )

      assert_offenses("", offenses)
    end

    def test_no_offense_in_for_loop_when_if_used
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            assign arr = 'a,b,c,d' | split: ','
            for el in arr
              if el == 'a'
                continue
              endif
              log el
            endfor
          %}
        END
      )

      assert_offenses("", offenses)
    end

    def test_reports_in_for_loop
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            assign arr = 'a,b,c,d' | split: ','
            for el in arr
              if el == "a""
                continue
                log el
              endif
              log el
            endfor
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `continue` at app/views/pages/index.liquid:5
      END
    end

    def test_no_offense_with_proper_complex_flow
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            if b
            endif
            if x
              assign y = "y value"
            elsif y == blank || y == "1"
              assign x = "hello"
              if z
                if a != b && a > 20
                  log "hello"
                  break
                endif
                  log "hello"
              endif
            endif
          %}
        END
      )

      assert_offenses('', offenses)
    end

    def test_reports_unreachable_string_when_break_is_used
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
            {% if a %}
              {% log "a" %}
              {% break %}
              {% log "unreachable" %}
            {% endif %}
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:3
      END
    end

    def test_reports_unreachable_string_when_break_is_used_followed_by_text
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
            {% break %}
            My text
          %}

        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:1
      END
    end

    def test_reports_unreachable_assign_when_return_is_used
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            return "example"
            assign x = "hello"
          %}

        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `return` at app/views/pages/index.liquid:2
      END
    end

    def test_reports_unreachable_code_in_if
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            if x
              break
              assign y = "unreachable"
            else
              assign x = "hello"
            endif
          %}

        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:3
      END
    end

    def test_reports_unreachable_code_in_unless
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            unless x
              break
              assign y = "unreachable"
            else
              assign x = "hello"
            endunless
          %}

        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:3
      END
    end

    def test_reports_unreachable_code_in_nested_if
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            assign x = "my value"
            if x
              assign y = "value"
            elsif y
              assign x = "hello"
              if z
                if a
                  log "hello"
                endif
                break
                log "hello"
              endif
            else
              assign y = "else value"
            endif
            if b
            endif
            print "Hello"
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:11
      END
    end

    def test_reports_unreachable_code_in_else
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            if a
              log "hello"
            else
              break
              log "hello"
            endif
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:5
      END
    end

    def test_reports_unreachable_code_in_case_when
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
            assign x = "my value"
            if x
              case x
              when "a"
                assign y = "a"
              when "b"
                break
                assign y = "b"
              else
                assign y = "else"
              endcase
            endif
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:8
      END
    end

    def test_reports_unreachable_code_in_case_else
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
              assign x = "hello"
              case x
              when "a"
                assign y = "hello"
              else
                log "my log"
                break
                assign y = "else"
              endcase
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:8
      END
    end

    def test_reports_unreachable_code_in_try
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
              assign x = "hello"
              try_rc
                graphql r = "send_api_call"
                break
                log "Hello"
              catch err
                log "my log"
              endtry_rc
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:5
      END
    end

    def test_reports_unreachable_code_in_catch
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
              assign x = "hello"
              try_rc
                graphql r = "send_api_call"
              catch err
                break
                log "my log"
              endtry_rc
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:6
      END
    end

    def test_reports_unreachable_code_in_ensure
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END
          {% liquid
              assign x = "hello"
              try_rc
                graphql r = "send_api_call"
              catch err
              ensure
                assign x = "hello"
                break
                log "my log"
              endtry_rc
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `break` at app/views/pages/index.liquid:8
      END
    end

    def test_reports_when_redirect_in_nested_include
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END,
          {% liquid
            function x = 'commands/create/x'
            if x.valid
              include "helpers/partial_with_redirect", url: "/example"
              log "Hello"
            else
              log "Not valid", type: "error"
            endif
          %}
        END
        "app/views/partials/helpers/partial_with_redirect.liquid" => <<~END
                  {% liquid
            if url == blank and context.session.return_to != blank
              assign url = context.session.return_to
            endif

            if context.params.return_to
              assign url = context.params.return_to | url_decode
            endif

            assign url = url | default: '/'

            assign not_start_with_slash = url | matches: '^(?!/)(.+)'
            assign wrong_url = url | matches: '^//'
            if not_start_with_slash or wrong_url
              assign url = '/'
            endif


            # platformos-check-disable ConvertIncludeToRender
            include 'modules/core/helpers/flash/publish', notice: notice, error: error, info: info
            # platformos-check-enable ConvertIncludeToRender

            if format == 'json'
              assign response_json = null | hash_merge: type: 'redirect', url: url
              if object.valid
                echo response_json
              else
                response_status 422
                assign res = '{ "errors": {} }' | parse_json
                hash_assign res['errors'] = response_json.errors

                echo res
              endif

            else
              redirect_to url
            endif

            break
          %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `include` at app/views/pages/index.liquid:4
      END
    end

    def test_reports_when_redirect_in_nested_nested_include_with_hidden_break
      offenses = analyze_platformos_app(
        UnreachableCode.new,
        "app/views/pages/index.liquid" => <<~END,
          {% liquid
            function x = 'commands/create/x'
            if x.valid
              include "helpers/partial_with_redirect", url: "/example"
              log "Hello"
            else
              log "Not valid", type: "error"
            endif
          %}
        END
        "app/views/partials/helpers/partial_with_redirect.liquid" => <<~END,
          {% log "this is log" %}
          {% redirect_to url %}
          {% include "helpers/partial_with_break" %}
        END
        "app/views/partials/helpers/partial_with_break.liquid" => <<~END
          {% log "this is another log" %}
          {% break %}
        END
      )

      assert_offenses(<<~END, offenses)
        Unreachable code after `include` at app/views/pages/index.liquid:4
      END
    end
  end
end
