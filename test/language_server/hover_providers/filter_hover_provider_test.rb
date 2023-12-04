# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  module LanguageServer
    class FilterHoverProviderTest < Minitest::Test
      include CompletionProviderTestHelper

      def setup
        @provider = FilterHoverProvider.new
      end

      def test_hovers_asset_url
        result = "### [asset_url](https://documentation.platformos.com/api-reference/liquid/filters/asset_url)\nGenerates CDN url to an asset\n\nParameters:\n- file_path - path to the asset, relative to assets directory\n\nReturns:\n- string: URL to the physical file if existing, root asset URL otherwise\n\n\n---\n\n\n  - Example 0:\n\n```liquid\n{{ \"valid/file.jpg\" | asset_url }}\n```\n##\nOutput: https://cdn-server.com/valid/file.jpg?updated=1565632488\n{{ \"nonexistent/file.jpg\" | asset_url }}"

        assert_can_hover_with(@provider, "{{ 'foo.js' | asset_url", result, 0, 0)
      end

      def test_hovers_l_filter_which_is_an_alias
        result = "### [localize](https://documentation.platformos.com/api-reference/liquid/filters/localize)\nParameters:\n- time - parsable time object to be formatted\n- format - the format to be used for formatting the time; default is 'long'; other values can be used:\nthey are taken from translations, keys are of the form 'time.formats.#!{format_name}'\n- zone - the time zone to be used for time\n- now - sets the time from which operation should be performed\n\nReturns:\n- string, nil: formatted representation of the passed parsable time\n\n\n---\n\n\n  - Example 0:\n\n```liquid\n{{ '2010-01-01' | localize }}\n```\n##\nOutput: 'January 01, 2010'\n  - Example 1:\n\n```liquid\n{{ 'in 14 days' | localize: 'long', '', '2011-03-15' }}\n```\n##\nOutput: 'March 14, 2011'"

        assert_can_hover_with(@provider, "{{ 'now' | to_time | l", result, 0, 0)
      end

      def test_hovers_array_group_by
        result = "### [array_group_by](https://documentation.platformos.com/api-reference/liquid/filters/array_group_by)\nTransforms array into hash, with keys equal to the values of object's method name and value being array containing objects\n\nParameters:\n- objects - array to be grouped\n- method_name - method name to be used to group Objects\n\nReturns:\n- hash: the original array grouped by method\nspecified by the second parameter\n\n\n---\n\n\n  - Example 0:\n\n```liquid\n{% parse_json objects %}\n  [\n    { \"size\": \"xl\", \"color\": \"red\"},\n    { \"size\": \"xl\", \"color\": \"yellow\"},\n    { \"size\": \"s\", \"color\": \"red\"}\n  ]\n{% endparse_json %}\n{{ objects | array_group_by: 'size' }}\n```\n##\nOutput: {\"xl\""

        assert_can_hover_with(@provider, "{{ foo | array_group_by", result, 0, 0)
      end

      def test_hovers_hash_merge
        result = "### [hash_merge](https://documentation.platformos.com/api-reference/liquid/filters/hash_merge)\nParameters:\n- hash1 - \n- hash2 - \n\nReturns:\n- hash: new hash containing the contents of hash1 and the contents of hash2.\nOn duplicated keys we keep value from hash2\n\n\n---\n\n\n  - Example 0:\n\n```liquid\n{% liquid\n  assign a = '{\"a\": 1, \"b\": 2 }' | parse_json\n  assign b = '{\"b\": 3, \"c\": 4 }' | parse_json\n  assign new_hash = a | hash_merge: b\n%}\n{{ new_hash }}\n```\n##\nOutput: { \"a\": 1, \"b\": 3, \"c\": 4 }\n  - Example 1:\n\n```liquid\n{% liquid\n  assign a = '{\"a\": 1}' | parse_json\n  assing a = a | hash_merge: b: 2, c: 3\n  %}\n{{ a }}\n```\n##\nOutput: { \"a\": 1, \"b\": 2, \"c\": 3 }"

        assert_can_hover_with(@provider, "{{ obj | hash_merge", result, 0, 0)
      end

      def test_hover_in_assign_tag
        result = "### [append](https://documentation.platformos.com/api-reference/liquid/filters/append)\nAdds a given string to the end of a string.\n\n---\n\n\n\nReturns:\n- string\n\n\n---\n\n\n  - Example 0:\n\n```liquid\n{%-  assign path = product.url -%}\n{{ request.origin | append: path }}\n```"

        assert_can_hover_with(@provider, "{% assign url = url | append: '#' | append", result, 0, 0)
      end

      def test_hover_in_parse_json
        result = "### [parse_json](https://documentation.platformos.com/api-reference/liquid/filters/parse_json)\nParameters:\n- object - String containing valid JSON\n- options - set to raw_text true to stop it from unescaping HTML entities\n\nReturns:\n- hash: Hash created based on JSON\n\n\n---\n\n\n  - Example 0:\n\n```liquid\n{% liquid\n  assign text = '{ \"name\": \"foo\", \"bar\": {} }'\n  assign object = text | parse_json\n%}\n{{ object.name }}\n```\n##\nOutput: 'foo'\n  - Example 1:\n\n```liquid\n{{ '{ \"key\": \"abc &quot; def\" }' | parse_json: raw_text: false }}\n```\n##\nOutput: { \"key\": 'abc \" def' }\n  - Example 2:\n\n```liquid\n{{ '{ \"key\": \"abc &quot; def\" }' | parse_json: raw_text: true }}\n```\n##\nOutput: { \"key\": 'abc &quot; def' }"

        assert_can_hover_with(@provider, "{% assign json = '{}' | parse_json", result, 0, 0)
      end

      def test_hover_in_default
        result = "### [default](https://documentation.platformos.com/api-reference/liquid/filters/default)\nSets a default value for any variable whose value is one of the following:\n\n- [`empty`](https://documentation.platformos.com/docs/api/liquid/basics#empty)\n- [`false`](https://documentation.platformos.com/docs/api/liquid/basics#truthy-and-falsy)\n- [`nil`](https://documentation.platformos.com/docs/api/liquid/basics#nil)\n\n---\n\nParameters:\n- allow_false - Whether to use false values instead of the default.\n\nReturns:\n- untyped\n\n\n---\n\n\n  - Example 0:\n\n```liquid\n{{ product.selected_variant.url | default: product.url }}\n```\n  - Example 1:\n\n```liquid\n{%- assign display_price = false -%}\n{{ display_price | default: true, allow_false: true }}\n```"

        assert_can_hover_with(@provider, "{% assign json = '{}' | default", result, 0, 0)
      end
    end
  end
end
