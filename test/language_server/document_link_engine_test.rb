# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class DocumentLinkEngineTest < Minitest::Test
      include PositionHelper

      def test_makes_links_out_of_render_tags
        content = <<~LIQUID
          {% render '1' %}
          {%- render "2" -%}
          {% liquid
            assign x = "x"
            render '3'
          %}
          {%- liquid
            assign x = "x"
            render "4"
          -%}
          {% render 'modules/my-module/hello/5' %}
          {% render 'modules/my-module/hello/6' %}
          {% render 'file/not_created_yet' %}
          {% render 'modules/my-module/file/not_created_yet' %}
        LIQUID

        engine = make_engine(
          "app/views/pages/product.liquid" => content,
          "app/views/partials/1.liquid" => '1',
          "app/lib/2.liquid" => '2',
          "app/lib/3.liquid" => '3',
          "app/views/partials/4.liquid" => '4',
          "modules/my-module/public/views/partials/hello/5.liquid" => '5',
          "modules/my-module/private/lib/hello/6.liquid" => '6'
        )

        assert_links_include("1", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("2", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("3", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("4", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("modules/my-module/hello/5", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/views/partials", ".liquid")
        assert_links_include("modules/my-module/hello/6", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/private/lib", ".liquid")
        assert_links_include("file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("modules/my-module/file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/views/partials", ".liquid")
      end

      def test_makes_links_out_of_function_tags
        content = <<~LIQUID
          {% function res = '1' %}
          {%- function res = "2", arg: 10 -%}
          {% liquid
            assign x = "x"
            function f = '3', x: x
          %}
          {%- liquid
            assign x = "x"
            function f = '4', x: x
          -%}
          {% function module_res = 'modules/my-module/hello/5' %}
          {% function module_res = 'modules/my-module/hello/6' %}
          {% function not_created = 'file/not_created_yet' %}
          {% function not_created_module = 'modules/my-module/file/not_created_yet' %}
        LIQUID

        engine = make_engine(
          "app/views/pages/product.liquid" => content,
          "app/views/partials/1.liquid" => '1',
          "app/lib/2.liquid" => '2',
          "app/lib/3.liquid" => '3',
          "app/views/partials/4.liquid" => '4',
          "modules/my-module/public/views/partials/hello/5.liquid" => '5',
          "modules/my-module/private/lib/hello/6.liquid" => '6'
        )

        assert_links_include("1", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("2", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("3", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("4", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("modules/my-module/hello/5", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/views/partials", ".liquid")
        assert_links_include("modules/my-module/hello/6", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/private/lib", ".liquid")
        assert_links_include("file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("modules/my-module/file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/lib", ".liquid")
      end

      def test_makes_links_out_of_graphql_tags
        content = <<~LIQUID
          {% graphql res = '1' %}
          {%- graphql res = "2", arg: 10 -%}
          {% liquid
            assign x = "x"
            graphql f = '3', x: x
          %}
          {% graphql res %}query { records(per_page: 20, table: { value: "my-table" }) { results { id } }}{% endgraphql%}
          {%- liquid
            assign x = "x"
            graphql f = '4', x: x
          -%}
          {% graphql module_res = 'modules/my-module/hello/5' %}
          {% graphql module_res = 'modules/my-module/hello/6' %}
          {% graphql not_created = 'file/not_created_yet' %}
          {% graphql not_created_module = 'modules/my-module/file/not_created_yet' %}
        LIQUID

        engine = make_engine(
          "app/views/pages/product.graphql" => content,
          "app/graphql/1.graphql" => '1',
          "app/graphql/2.graphql" => '2',
          "app/graphql/3.graphql" => '3',
          "app/graphql/4.graphql" => '4',
          "modules/my-module/public/graphql/hello/5.graphql" => '5',
          "modules/my-module/private/graphql/hello/6.graphql" => '6'
        )

        assert_links_include("1", content, engine.document_links("app/views/pages/product.graphql"), "app/graphql", ".graphql")
        assert_links_include("2", content, engine.document_links("app/views/pages/product.graphql"), "app/graphql", ".graphql")
        assert_links_include("3", content, engine.document_links("app/views/pages/product.graphql"), "app/graphql", ".graphql")
        assert_links_include("4", content, engine.document_links("app/views/pages/product.graphql"), "app/graphql", ".graphql")
        assert_links_include("modules/my-module/hello/5", content, engine.document_links("app/views/pages/product.graphql"), "modules/my-module/public/graphql", ".graphql")
        assert_links_include("modules/my-module/hello/6", content, engine.document_links("app/views/pages/product.graphql"), "modules/my-module/private/graphql", ".graphql")
        assert_links_include("file/not_created_yet", content, engine.document_links("app/views/pages/product.graphql"), "app/graphql", ".graphql")
        assert_links_include("modules/my-module/file/not_created_yet", content, engine.document_links("app/views/pages/product.graphql"), "modules/my-module/public/graphql", ".graphql")
      end

      def test_makes_links_out_of_background_tags
        content = <<~LIQUID
          {% background res = '1' %}
          {%- background res = "2", arg: 10 -%}
          {% liquid
            assign x = "x"
            background f = '3', x: x
          %}
          {%- liquid
            assign x = "x"
            background f = '4', x: x
          -%}
          {% background module_res = 'modules/my-module/hello/5' %}
          {% background module_res = 'modules/my-module/hello/6' %}
          {% background not_created = 'file/not_created_yet' %}
          {% background not_created_module = 'modules/my-module/file/not_created_yet' %}
        LIQUID

        engine = make_engine(
          "app/views/pages/product.liquid" => content,
          "app/views/partials/1.liquid" => '1',
          "app/lib/2.liquid" => '2',
          "app/lib/3.liquid" => '3',
          "app/views/partials/4.liquid" => '4',
          "modules/my-module/public/views/partials/hello/5.liquid" => '5',
          "modules/my-module/private/lib/hello/6.liquid" => '6'
        )

        assert_links_include("1", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("2", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("3", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("4", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("modules/my-module/hello/5", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/views/partials", ".liquid")
        assert_links_include("modules/my-module/hello/6", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/private/lib", ".liquid")
        assert_links_include("file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("modules/my-module/file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/lib", ".liquid")
      end

      def test_makes_links_out_of_include_tags
        content = <<~LIQUID
          {% include '1' %}
          {%- include "2" -%}
          {% liquid
            assign x = "x"
            include '3'
          %}
          {%- liquid
            assign x = "x"
            include "4"
          -%}
          {% include 'modules/my-module/hello/5' %}
          {% include 'modules/my-module/hello/6' %}
          {% include 'file/not_created_yet' %}
          {% include 'modules/my-module/file/not_created_yet' %}
        LIQUID

        engine = make_engine(
          "app/views/pages/product.liquid" => content,
          "app/views/partials/1.liquid" => '1',
          "app/lib/2.liquid" => '2',
          "app/lib/3.liquid" => '3',
          "app/views/partials/4.liquid" => '4',
          "modules/my-module/public/views/partials/hello/5.liquid" => '5',
          "modules/my-module/private/lib/hello/6.liquid" => '6'
        )

        assert_links_include("file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("modules/my-module/file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/views/partials", ".liquid")
        assert_links_include("1", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("2", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("3", content, engine.document_links("app/views/pages/product.liquid"), "app/lib", ".liquid")
        assert_links_include("4", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid")
        assert_links_include("modules/my-module/hello/5", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/views/partials", ".liquid")
        assert_links_include("modules/my-module/hello/6", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/private/lib", ".liquid")
      end

      def test_makes_links_out_of_include_form_tags
        content = <<~LIQUID
          {% include_form '1' %}
          {%- include_form "2" -%}
          {% liquid
            assign x = "x"
            include_form '3'
          %}
          {%- liquid
            assign x = "x"
            include_form "4"
          -%}
          {% include_form 'modules/my-module/hello/5' %}
          {% include_form 'modules/my-module/hello/6' %}
          {% include_form 'file/not_created_yet' %}
          {% include_form 'modules/my-module/file/not_created_yet' %}
        LIQUID

        engine = make_engine(
          "app/views/pages/product.liquid" => content,
          "app/forms/1.liquid" => '1',
          "app/forms/2.liquid" => '2',
          "app/forms/3.liquid" => '3',
          "app/forms/4.liquid" => '4',
          "modules/my-module/public/forms/hello/5.liquid" => '5',
          "modules/my-module/private/forms/hello/6.liquid" => '6'
        )

        assert_links_include("file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "app/forms", ".liquid")
        assert_links_include("modules/my-module/file/not_created_yet", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/forms", ".liquid")
        assert_links_include("1", content, engine.document_links("app/views/pages/product.liquid"), "app/forms", ".liquid")
        assert_links_include("2", content, engine.document_links("app/views/pages/product.liquid"), "app/forms", ".liquid")
        assert_links_include("3", content, engine.document_links("app/views/pages/product.liquid"), "app/forms", ".liquid")
        assert_links_include("4", content, engine.document_links("app/views/pages/product.liquid"), "app/forms", ".liquid")
        assert_links_include("modules/my-module/hello/5", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/forms", ".liquid")
        assert_links_include("modules/my-module/hello/6", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/private/forms", ".liquid")
      end

      def test_makes_links_out_of_asset_url_filters
        content = <<~LIQUID
          {{ '1.js' | asset_url }}
          {{- "2.css" | asset_url -}}
          {% liquid
            assign x = 'file/3.js' | asset_url
            echo '4' | asset_url
          %}
          {%- liquid
            assign x = "5" | asset_url
            echo "6" | asset_url
          -%}
          {{ 'modules/my-module/hello/5.js' | asset_url }}
          {{ 'modules/my-module/hello/6.jpg' | asset_url }}
        LIQUID

        engine = make_engine(
          "app/views/pages/product.liquid" => content,
          "modules/my-module/private/assets/hello/6.jpg" => '6'
        )

        assert_links_include("1.js", content, engine.document_links("app/views/pages/product.liquid"), "app/assets", "")
        assert_links_include("2.css", content, engine.document_links("app/views/pages/product.liquid"), "app/assets", "")
        assert_links_include("file/3.js", content, engine.document_links("app/views/pages/product.liquid"), "app/assets", "")
        assert_links_include("4", content, engine.document_links("app/views/pages/product.liquid"), "app/assets", "")
        assert_links_include("5", content, engine.document_links("app/views/pages/product.liquid"), "app/assets", "")
        assert_links_include("6", content, engine.document_links("app/views/pages/product.liquid"), "app/assets", "")
        assert_links_include("modules/my-module/hello/5.js", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/assets", "")
        assert_links_include("modules/my-module/hello/6.jpg", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/private/assets", "")
      end

      def test_makes_links_out_of_theme_render_tags
        content = <<~LIQUID
          {% theme_render_rc '1' %}
          {%- theme_render_rc "2" -%}
          {% liquid
            assign x = "x"
            theme_render_rc '3'
          %}
          {%- liquid
            assign x = "x"
            theme_render_rc "4"
          -%}
          {% theme_render_rc 'hello/5' %}
          {% theme_render_rc 'modules/my-module/hello/6' %}
        LIQUID

        engine = make_engine(
          "app/config.yml" => <<~END,
            ---
            theme_search_paths:
              - ''
              - theme/{{ context.constants.THEME }}
              - theme/selected/
              - theme/default
              - modules/my-module
            ---
          END
          "app/views/pages/product.liquid" => content,
          "app/views/partials/theme/selected/1.liquid" => '1',
          "app/views/partials/theme/default/1.liquid" => '1',
          "app/lib/theme/default/2.liquid" => '2',
          "app/lib/theme/selected/3.liquid" => '3',
          "app/views/partials/4.liquid" => '4',
          "modules/my-module/public/views/partials/hello/5.liquid" => '5',
          "modules/my-module/private/lib/hello/6.liquid" => '6'
        )

        assert_links_include("1", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials/theme/selected", ".liquid", skip_range_check: true)
        assert_links_include("2", content, engine.document_links("app/views/pages/product.liquid"), "app/lib/theme/default", ".liquid", skip_range_check: true)
        assert_links_include("3", content, engine.document_links("app/views/pages/product.liquid"), "app/lib/theme/selected", ".liquid", skip_range_check: true)
        assert_links_include("4", content, engine.document_links("app/views/pages/product.liquid"), "app/views/partials", ".liquid", skip_range_check: true)
        assert_links_include("modules/my-module/hello/5", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/views/partials", ".liquid", skip_range_check: true)
        assert_links_include("modules/my-module/hello/6", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/private/lib", ".liquid", skip_range_check: true)
      end

      def test_makes_links_for_translations
        content = <<~LIQUID
          {{ 'app.item.title' | t }}
          {{- "app.item.text" | t_escape -}}
          {% liquid
            assign x = my_var | default: 'app.item.details.missing' | t
            echo 'app.errors.presence' | translate
            assign t = 'uniq' | translate: default: "World": scope: 'app.errors'
          %}
          {%- liquid
            assign x = "app.item.discount" | t: amount: "20%"
          -%}
          {%- print 'sell' | t: scope: "modules/my-module/app.item" %}
          {{ 'modules/my-module/app.item.buy' | t: default: "Buy now" }}
          {{ '2023-10-03' | to_date }}
        LIQUID

        engine = make_engine(
          "app/views/pages/product.liquid" => content,
          "app/translations/en/item.yml" => <<~YML,
            en:
              compact: "Compact"
              app:
                item:
                  title: "Item"
                  text: "This is text"
                  discount: "Discount %<amount>s"
          YML
          "app/translations/en/error.yml" => <<~YML,
            en:
              app:
                errors:
                  presence: "must be present"
                  uniq: "must be uniq"
          YML
          "modules/my-module/public/translations/en/item.yml" => <<~YML,
            en:
              app:
                item:
                  buy: "Buy"
          YML
          "modules/my-module/private/translations/en/item2.yml" => <<~YML,
            en:
              app:
                item:
                  sell: "Sell"
          YML
          "modules/my-module/public/translations/en/item_details.yml" => <<~YML,
            en:
              app:
                item:
                  details:
                    title: "Title"
          YML
          "app/translations/en/item_details.yml" => <<~YML,
            en:
              app:
                item:
                  details:
                    title: "Title"
          YML
          "app/translations/en/date.yml" => <<~YML
            en:
              time:
                formats:
                  compact: "%Y-%d-%m %H:%M"
              date:
                formats:
                  compact: "%Y-%d-%m %H:%M"
          YML
        )

        assert_translation_include("app.item.title", content, engine.document_links("app/views/pages/product.liquid"), "app/translations/en/item.yml")
        assert_translation_include("app.item.text", content, engine.document_links("app/views/pages/product.liquid"), "app/translations/en/item.yml")
        assert_translation_include("app.item.details.missing", content, engine.document_links("app/views/pages/product.liquid"), "app/translations/en/item_details.yml")
        assert_translation_include("app.errors.presence", content, engine.document_links("app/views/pages/product.liquid"), "app/translations/en/error.yml")
        assert_translation_include("uniq", content, engine.document_links("app/views/pages/product.liquid"), "app/translations/en/error.yml")
        assert_translation_include("app.item.discount", content, engine.document_links("app/views/pages/product.liquid"), "app/translations/en/item.yml")
        assert_translation_include("modules/my-module/app.item.buy", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/public/translations/en/item.yml")
        assert_translation_include("sell", content, engine.document_links("app/views/pages/product.liquid"), "modules/my-module/private/translations/en/item2.yml")

        # do not generate documentLink for filters that start with `t`, like for example `to_date`
        lines = content.split("\n")
        lines_with_to_date = lines.size.times.select { |i| lines[i].include?('to_date') } # => [0, 2, 6]

        assert_nil(engine.document_links("app/views/pages/product.liquid").detect { |link| lines_with_to_date.include?(link[:range][:start][:line]) })
      end

      def test_makes_links_for_localizations
        content = <<~LIQUID
          {{ '2021-02-20T11:06:37.718Z' | l: 'compact', context.timezone }}
          {{ var | l: 'compact', context.timezone }}
          {% liquid
            assign now = 'now' | to_time
            print now | l: 'long', context.timezone }}
          %}
          {% echo var | l:"ymd" %}
        LIQUID

        engine = make_engine(
          "app/views/pages/product.liquid" => content,
          "app/translations/en/base.yml" => <<~YML,
            en:
              compact: "Compact"
              ymd: "YMD"
          YML
          "app/translations/en/date.yml" => <<~YML
            en:
              time:
                formats:
                  compact: "%Y-%d-%m %H:%M"
                  long: "%Y-%d-%m %H:%M%Z"
              date:
                formats:
                  compact: "%Y-%d-%m "
                  ymd: "%Y-%m-%d"
          YML
        )

        assert_translation_include("compact", content, engine.document_links("app/views/pages/product.liquid"), "app/translations/en/date.yml")
        assert_translation_include("long", content, engine.document_links("app/views/pages/product.liquid"), "app/translations/en/date.yml")
        assert_translation_include("ymd", content, engine.document_links("app/views/pages/product.liquid"), "app/translations/en/date.yml")
      end

      def assert_links_include(needle, content, links, directory, extension, skip_range_check: false, needle_path: nil)
        needle_path ||= needle.start_with?('modules/') ? needle.split('/').drop(2).join('/') : needle
        target = "file:///tmp/#{directory}/#{needle_path}#{extension}"
        match = links.find { |x| x[:target] == target }

        refute_nil(match, "Should find a document_link with target == '#{target}'")

        return if skip_range_check

        assert_equal(
          from_index_to_row_column(content, content.index(needle)),
          [
            match.dig(:range, :start, :line),
            match.dig(:range, :start, :character)
          ]
        )

        assert_equal(
          from_index_to_row_column(content, content.index(needle) + needle.size),
          [
            match.dig(:range, :end, :line),
            match.dig(:range, :end, :character)
          ]
        )
      end

      def assert_translation_include(translation, content, links, path)
        target = "file:///tmp/#{path}"

        content_index = content.index(translation)
        if content_index
          start_line, start_column = from_index_to_row_column(content, content_index)
          end_line, end_column = from_index_to_row_column(content, content_index + translation.size)

          match = links.find do |x|
            x[:target] == target &&
              x[:range][:start][:line] == start_line &&
              x[:range][:start][:character] == start_column &&
              x[:range][:end][:line] == end_line &&
              x[:range][:end][:character] == end_column
          end

          refute_nil(match, "Should find a document_link with target == '#{target}' at #{start_line}:#{start_column}-#{end_line}:#{end_column}, received: #{links}")
        else
          refute_nil(content_index, "Cannot find document link for `#{translation}`")
        end
      end

      private

      def make_engine(files)
        storage = InMemoryStorage.new(files, "/tmp")
        DocumentLinkEngine.new(storage)
      end
    end
  end
end
