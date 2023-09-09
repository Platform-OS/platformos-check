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

      def assert_links_include(needle, content, links, directory, extension)
        needle_path = needle.start_with?('modules/') ? needle.split('/').drop(2).join('/') : needle
        target = "file:///tmp/#{directory}/#{needle_path}#{extension}"
        match = links.find { |x| x[:target] == target }

        refute_nil(match, "Should find a document_link with target == '#{target}'")

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

      private

      def make_engine(files)
        storage = InMemoryStorage.new(files, "/tmp")
        DocumentLinkEngine.new(storage)
      end
    end
  end
end
